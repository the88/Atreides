class Atreides::Tweet < Atreides::Base

  #
  # Constants
  #

  #
  # Associatons
  #

  #
  # Validations
  #
  validates_presence_of :twitter_id, :text, :from_user, :tweeted_at
  validates_uniqueness_of :twitter_id

  class << self
    def analytics(since = 1.month.ago)
      days = select("count(id) as twitter_id, sum(reach) as reach, DATE(tweeted_at) as tweeted_at").
        where("tweeted_at > ?", since).
        group("DATE(tweeted_at)").order(:twitter_id).map { |t|
          {
            :tweets => t.twitter_id,
            :reach => t.reach,
            :date => t.tweeted_at.to_date
          }
        }
    end

    def exposure(since = 1.month.ago)
      where("tweeted_at > ?", since).sum(:reach)
    end

    def reach(since = 1.month.ago)
      select("distinct(from_user), reach").where("tweeted_at > ?", since).to_a.sum(&:reach)
    end

    # Get most recent
    def fetch_recent(started_at = nil)
      # Twitter mentions
      started_at ||= Time.zone.now
      continue = true
      users = []
      per_page = 100

      while continue do
        # Get most recent tweets
        tweets = twitter[:search].search.json?(
          :q => Settings.twitter.search_for, 
          :since_id => Atreides::Tweet.maximum(:twitter_id),
          # :since => (Atreides::Tweet.maximum(:tweeted_at) || 1.month.ago).to_date.to_s,
          # :max_id => self.minimum(:twitter_id, :conditions => ["created_at >= ?", started_at]),
          :rpp => per_page, 
          :lang => "all"
        ).results

        if continue = !tweets.size.zero?
          # Get user ids
          user_ids = tweets.map(&:from_user).uniq
          page = 0

          # Don't double fetch user-ids
          unless users.empty?
            user_ids -= users.map(&:screen_name).map(&:downcase)
          end

          continue_u = true
          while continue_u do
            sub_users = user_ids[page*per_page .. (page+1)*per_page] || []
            if continue_u = !sub_users.size.zero?
              page +=1
              results = twitter.users.lookup.json?(:screen_name => sub_users.join(','))
              # Append to list
              users += results
            end
          end

          # Add to DB
          tweets.each do |twt|
            u = users.detect{|u|u.screen_name.downcase==twt.from_user}
            self.create(
              :twitter_id => twt.id, 
              :tweeted_at => Time.zone.parse(twt.created_at),
              :text => twt.text,
              :from_user => twt.from_user,
              :to_user => twt.to_user,
              :reach => (u ? u.followers_count : 0), 
              :profile_image_url => twt.profile_image_url
            )
          end
        end

        # Return new tweets created
        where("created_at >= ?", started_at).count(:id)
      end
    end

    private

    def twitter
      require 'grackle' unless defined?(Grackle)
      @twitter ||= Grackle::Client.new(:auth => {
        :type => :oauth,
        :consumer_key => Settings.twitter.consumer_key, 
        :consumer_secret => Settings.twitter.consumer_secret,
        :token => Settings.twitter.app_user_token, 
        :token_secret => Settings.twitter.app_user_secret
      })
      # Show debugging info
      @twitter.transport.debug = true unless Rails.env.production?
      @twitter
    end

  end

  private

  def twitter
    self.class.twitter
  end

  include Atreides::Extendable
end
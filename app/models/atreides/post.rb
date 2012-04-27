class Atreides::Post < Atreides::Base

  include Atreides::Base::Taggable
  include Atreides::Base::AasmStates
  include Atreides::Base::Validation

  #
  # Constants
  #

  #
  # Associatons
  #
  has_many :parts, :as => :contentable, :order => "display_order", :class_name => "Atreides::ContentPart", :dependent => :destroy
  has_many :features, :class_name => "Atreides::Feature"
  belongs_to :site, :class_name => "Atreides::Site"
  belongs_to :tw_delayed_job, :class_name => "::Delayed::Job"
  belongs_to :fb_delayed_job, :class_name => "::Delayed::Job"
  belongs_to :tumblr_delayed_job, :class_name => "::Delayed::Job"
  belongs_to :author, :class_name => "Atreides::User"
  belongs_to :last_editor, :class_name => "Atreides::User"

  #
  # Behaviours
  #

  attr_accessor :url, :tw_me, :fb_me, :tumblr_me
  accepts_nested_attributes_for :parts, :allow_destroy => true

  #
  # Validations
  #
  validate :site_id, :presence => true
  validates :title, :presence => true, :if => :published?
  validates :slug, :presence => { :message => "can't be blank. Did you set a title?" }, :if => :published?
  validates :social_msg, :length => { :within => 0..140 }, :if => :social_msg?
  validate :content_parts

  #
  # Scopes
  #
  default_scope order("posts.published_at desc, posts.id desc")

  scope :for_month, lambda { |date, col|
    col ||= :published_at
    where("#{col} >= ? AND #{col} <= ?", date.to_time.beginning_of_month, date.to_time.end_of_month)
  }

  scope :by_month, lambda { |*args|
    # Needs to be sep variable or AR will cache the first time and it'll never change
    now = Time.zone.now
    select("distinct(EXTRACT(DAY from posts.published_at)), posts.*").
    where("EXTRACT(MONTH from posts.published_at) = ? and EXTRACT(YEAR from posts.published_at) = ? and posts.published_at <= ?",  args.flatten[0].to_i, now.year, now).
    order("posts.published_at asc")
  }

  scope :by_year, lambda { |year|
    # Needs to be sep variable or AR will cache the first time and it'll never change
    where("EXTRACT(YEAR from posts.published_at) = ? and posts.published_at <= ?",  year.to_i, Time.zone.now)
  }

  scope :popular_photos, lambda {
    now = Time.zone.now
    joins("INNER JOIN photos ON photos.photoable_type = 'Atreides::Post' AND photos.photoable_id = posts.id").
    select("posts.*, ((comments_count*2)+likes_count) as final_count").
    where("posts.state = 'published' AND posts.published_at < ? AND posts.published_at < ?", now-1.week, now).
    order("final_count desc, published_at desc").
    group("posts.id").
    limit(6)
  }

  #
  # Callbacks
  #
  after_initialize :setup_social_network
  after_initialize :set_diary

  def setup_social_network
    # Setup social network callback flags
    begin
      self.tw_me      ||= ((Settings.default_cross_post_to?(:twitter)  && pending?) or tw_delayed_job_id?) unless twitter_id?
      self.fb_me      ||= ((Settings.default_cross_post_to?(:facebook) && pending?) or fb_delayed_job_id?) unless facebook_id?
      self.tumblr_me  ||= ((Settings.default_cross_post_to?(:tumblr)   && pending?) or tumblr_delayed_job_id?) unless tumblr_id?
    rescue
    end
  end

  def set_diary
    # Set diary as default location
    if pending? or new_record? and respond_to?(:location_list) and location_list.empty?
      location_list << Settings.tags.posts.location.first
    end
  end

  before_save :push_publication
  after_save :push_to_social

  def push_publication
    # If have just been saved as published then do do_publish to post to twitter/fb etc
    do_publish if (state_changed? and published?) or (!state_changed? and published_at_changed?)
  end

  def push_to_social
    # Atreides::Post to social networks
    social_cross_posts if published? and (tw_me or fb_me or tumblr_me)
  end

  #
  # Class Methods
  #
  class << self

    def next(post)
      with_exclusive_scope { 
        # Due to problems with the default_scope ordering the 'live' scope must come AFTER the order scope
        where("published_at >= ? and id != ?", post.published_at, post.id).order("published_at asc, id asc").live.first
      }
    end

    def previous(post)
      with_exclusive_scope { 
        # Due to problems with the default_scope ordering the 'live' scope must come AFTER the order scope
        where("published_at <= ? and id != ?", post.published_at, post.id).order("published_at desc, id desc").live.first
      }
    end

    def next_month(month = Date.today.month)
      p = self.live.first(:conditions => ["EXTRACT(MONTH from published_at) > ?", month.to_i], :order => "published_at asc, id desc")
      p ? p.published_at.month : nil
    end

    def previous_month(month = Date.today.month)
      p = self.live.first(:conditions => ["EXTRACT(MONTH from published_at) < ?", month.to_i], :order => "published_at desc, id desc")
      p ? p.published_at.month : nil
    end

    def base_class
      self
    end
  end

  #
  # Instance Methods
  #
  def to_param
    # Used for urls like /posts/:id/:slug
    id.to_s
  end

  def next
    @_next ||= self.class.next(self)
  end

  def previous
    @_previous ||= self.class.previous(self)
  end

  def related_posts
    # Don't recalc twice
    return @related_posts unless @related_posts.nil?

    max = 6
    @related_posts  = []
    @related_posts += Atreides::Post.live.tagged_with(tag_list, :match_all => :true).all(:conditions => ["posts.id not in (?)", [id]], :limit => max) rescue []
    @related_posts += Atreides::Post.live.tagged_with(tag_list, :any       => :true).all(:conditions => ["posts.id not in (?)", @related_posts.map(&:id)+[id]], :limit => max - @related_posts.size) if @related_posts.size < max rescue []
    @related_posts.uniq!
    @related_posts += Atreides::Post.live.all(:conditions => ["posts.id not in (?)", @related_posts.map(&:id)+[id]], :limit => max - @related_posts.size) if @related_posts.size < max rescue []
    @related_posts
  end
  
  # Return the first found text/video/photo
  def first_body
    (part = parts.where(:content_type => :text).detect{|p| p.body? }) ? part.body : ""
  end
  alias_method :body, :first_body
  
  def first_photo
    (part = parts.where(:content_type => :photos).detect{|p| !p.photos.first.nil? }) ? part.photos.first : nil
  end
  alias_method :photo, :first_photo

  def first_video
    (part = parts.where(:content_type => :videos).detect{|p| !p.videos.first.nil? }) ? part.videos.first : nil
  end
  alias_method :video, :first_video
  
  # Return the first found photo
  def thumbnail(size = :thumb)
    # Find the first thumbnail image
    url = if first_photo
      first_photo.image.url(size)
    elsif first_video
      first_video.thumb_url
    end
    url || "/images/missing_thumb.png"
  end
  

  def update_twitter_id(twitter_id)
    self.twitter_id = twitter_id
    save
  end

  def update_facebook_id(facebook_id)
    self.facebook_id = facebook_id
    save
  end

  def update_tumblr_id(tumblr_id)
    self.tumblr_id = tumblr_id
    save
  end

  def post_types
    @post_types ||= parts.map {|part| part.content_type}
  end

  def slug=(value)
    # Do not let id based slugs through
    write_attribute(:slug, value.to_s.match(/^\d+$/) ? nil : value)
  end

  # Make social posting flags understand booleans and form submitted num booleans
  def tw_me=(value)
    @tw_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end

  def fb_me=(value)
    @fb_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end

  def tumblr_me=(value)
    @tumblr_me = (value.is_a?(TrueClass) || value.is_a?(FalseClass)) ? value : !value.to_i.zero?
  end
  
  private

  def content_parts
    errors.add(:parts, "cannot be empty. Add some content!") if parts.empty? and published?
  end

  def do_publish(msg = nil)
    self.published_at = Time.zone.now if published_at.nil?
  end

  def social_cross_posts
    %w(tw fb).each do |prefix|
      next unless self.send("#{prefix}_me")

      assoc = "#{prefix}_delayed_job"

      # No Delayed Job id set or is failed? Then create one.
      if !self.send("#{assoc}_id?") or (self.send(assoc) and self.send(assoc).failed_at?)
        # Create new instance of class that will post to the soc network
        job = "#{prefix.capitalize}PostPublisherJob".constantize.new(self.id)
        dj = ::Delayed::Job.enqueue :payload_object => job, :priority =>  0, :run_at => self.published_at
        self.send("#{assoc}=", dj)

        # If already got a delayed job awaiting, then update the exec date
      elsif self.send(assoc) and self.send(assoc).run_at != self.published_at
        self.send(assoc).update_attribute(:run_at, self.published_at)
      end
    end
  end

  include Atreides::Extendable
end

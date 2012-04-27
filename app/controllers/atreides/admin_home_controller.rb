class Atreides::AdminHomeController < Atreides::ApplicationController
  layout 'admin'

  inherit_resources

  after_filter :set_last_modified
  before_filter :set_date, :only => [:index, :filter]
  before_filter :set_expires, :only => [:analytics_data]
  skip_before_filter :verify_authenticity_token, :only => [:analytics_data]
  # around_filter :cache, :only => [:analytics_data]

  before_filter :ensure_atreides_setup, :only => [:index, :search]
  before_filter :setup_only_once!, :only => [:setup, :setup!]

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "AdminHomeController: CanCan::AccessDenied #{exception.inspect}, admin?: #{current_user && !current_user.admin?}; #{current_user.inspect}"
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
    else
      redirect_to new_user_session_path, :notice => exception.message
    end
  end

  def collection
    nil
  end

  def setup
    @user = Atreides::User.new
  end
  def setup!
    @user = Atreides::User.new params[:user]
    @user.role = :admin
    if @user.save
      sign_in @user
      redirect_to :admin
    else
      render "setup"
    end
  end


  def index
    if cannot? :read, Atreides::Tweet
      raise CanCan::AccessDenied
    end
    @show_as_dash = true
    @reports = google_analytics_reports

    # Twitter mentions
    # Group by the date of the tweet
    @since = 1.month.ago.to_date
    @tweet_exposure = Atreides::Tweet.exposure(@since)
    @tweet_reach = Atreides::Tweet.reach(@since)
  end

  def analytics_data
    # TODO: parameterize the dates
    if params[:since]
      @since = Date.parse(params[:since]).beginning_of_day.to_date
      @until = (@since + 31.days).beginning_of_day.to_date
      @until = Date.today if @until > Date.today
    else
      @since = 1.month.ago.beginning_of_day.to_date
      @until = Time.now.beginning_of_day.to_day
    end

    puts "From #{@since.to_s} to #{@until.to_s}"

    @report_name = report_name = params[:report].to_sym

    case @report_name
    when *google_analytics_reports.keys
      @report = google_analytics_reports[@report_name].update({ :start_date => @since.to_s, :end_date => @until.to_s})

      @report[:results] = fetch_with_caching(30.minutes) do
        gs = Gattica.new({:email => Settings.ganalytics.email, :password => Settings.ganalytics.password, :profile_id => Settings.ganalytics.profile_id})
        gs.get(@report)
      end
    when :tweets
      @tweets = Atreides::Tweet.analytics(@since)
    when :fb_page_views
      # Facebook insights API
      if Settings.facebook && Settings.facebook.page_token && Settings.facebook.page_id
        # @fb_page_views = fb.get(Settings.facebook.page_id, :type => 'insights/page_views/day', :params => {:since => @since})
        @fb_page_views = fetch_with_caching(5.minutes) do
          fb.get(Settings.facebook.page_id, :type => 'insights/page_impressions/day', :params => {:since => @since})
        end
      end
    when :fb_page_likes
      # Facebook insights API
      if Settings.facebook && Settings.facebook.page_token && Settings.facebook.page_id
        # @fb_page_likes = fb.get(Settings.facebook.page_id, :type => 'insights/page_like_adds/day', :params => {:since => @since})
        @fb_page_likes = fetch_with_caching(5.minutes) do
          fb.get(Settings.facebook.page_id, :type => 'insights/page_fan_adds/day', :params => {:since => @since})
        end
      end
    else
      raise RuntimeError.new "UnknownReport: #{@report_name.inspect}"
    end
    render "_#{@report_name}_analytics_tbody", :layout => nil
  end

  def search
    raise CanCan::AccessDenied if cannot?(:read, Atreides::Post) || cannot?(:read, Atreides::Page)

    @query = params[:search].to_s.strip
    like_q = "%#{@query}%".downcase
    conds  = ["LOWER(state) like ? or LOWER(title) like ?", like_q, like_q]
    tag    = Atreides::Tag.find_by_name(@query)
    content_part_ids = Atreides::ContentPart.where("contentable_type = 'Atreides::Post' and LOWER(body) like ?", like_q).all.map(&:contentable_id)

    @results = {
      :posts    =>  current_site.posts.
                    where("LOWER(state) like ? or LOWER(title) like ? or id in (?)", like_q, like_q, content_part_ids).
                    paginate(:page => 1),

      :pages    =>  current_site.pages.
                    where("LOWER(state) like ? or LOWER(body) like ? or LOWER(title) like ?", like_q, like_q, like_q).
                    paginate(:page => 1)
    }
    respond_to do |wants|
      wants.html {
       render :template => "atreides/admin_home/search"
      }
    end
  end

  def switch_site
    # Set current-site if param matches an existing one
    if s = Atreides::Site.find_by_name(params[:site])
      @current_site = s
      session[:site_name] = s.name
    end
    flash[:notice] = t('atreides.atreides.admin_home.switch_site.site_changed', :current_site => current_site.name)
    redirect_to request.env["HTTP_REFERER"] || admin_path
  end

  private

  def set_date
    @date ||= if params[:month] || params[:year]
      "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
    else
      Date.today
    end
  end

  def end_of_association_chain
    current_site.posts
  end

  def ensure_atreides_setup
    if atreides_setup?
      true
    else
      redirect_to :atreides_setup
      false
    end
  end

  def setup_only_once!
    raise "Atreides is already set up !" if atreides_setup?
  end

  def google_analytics_reports
    {
      :visitors => {
        :dimensions => %w(day),
        :metrics => %w(visits)
      },
      :top_referrers => {
        :dimensions => %w(source),
        :metrics => %w(visits),
        :sort => %w(-visits)
      },
      :top_landing_pages => {
        :dimensions => %w(landingPagePath),
        :metrics => %w(uniquePageviews),
        :sort => %w(-uniquePageviews)
      }
    }
  end

  def with_profiling activity
    puts Rails.logger.info "#{activity.capitalize}..."
    prof_start = Time.now.to_f
    res = yield
    res.tap {
      puts Rails.logger.info "Done #{activity} in #{Time.now.to_f - prof_start} seconds."
    }
  end

  def fb
    MiniFB.disable_logging
    @fb ||= MiniFB::OAuthSession.new(Settings.facebook.page_token)
  end

  def fetch_with_caching(duration, &block)
    report_name = @report_name
    cache_key = "analytics_data:#{@report_name}:#{@since}"
    cached = Rails.cache.fetch(cache_key,  :expires_in => duration) do
      fetched = with_profiling "getting report #{report_name.inspect}", &block
      Marshal.dump fetched
    end
    Marshal.restore StringIO.new cached
  end

  include Atreides::Extendable
end

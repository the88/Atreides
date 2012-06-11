class Atreides::AdminController < Atreides::ApplicationController

  inherit_resources
  def self.inherited(base)
    super
    resource_class_name = base.name.sub(/Admin::/, '').sub(/Controller/, '').singularize
    base.resource_class = resource_class_name.constantize
    base.resources_configuration[:self][:request_name] = base.resource_class.to_s.sub(/Atreides::/, '').underscore.gsub('/', '_')
  end

  load_and_authorize_resource :class => resource_class

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "AdminController: CanCan::AccessDenied #{exception.inspect}, admin?: #{current_user && !current_user.admin?}; #{current_user.inspect}"
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
    else
      if atreides_setup?
        redirect_to new_user_session_path, :notice => exception.message
      else
        redirect_to atreides_setup_path
      end
    end
  end

  before_filter :set_date, :only => [:index, :filter]
  before_filter :set_expires, :only => [:analytics]
  around_filter :cache, :only => [:analytics]
  skip_before_filter :verify_authenticity_token, :only => [:analytics]
  after_filter :set_last_modified
  before_filter :set_resource_request_name

  layout 'admin'

  private

  def set_resource_request_name
    @resource_request_name = self.resources_configuration[:self][:request_name]
  end

  # temporary fix for AR bug: https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/6723
  def fix_rails_bug
    keys = %w(post page) & params.keys
    keys.map do |k|
      params[k].merge!(:photos_attributes => params[k].delete(:photos_attributes)) if params[k].has_key? :photos_attributes
    end
  end

  def resource_params
    fix_rails_bug
    super
  end

  def current_site
    # Use session as key for
    @current_site ||= if session[:site_name]
      Atreides::Site.find_by_name(session[:site_name])
    elsif !request.subdomains.empty?
      Atreides::Site.find_by_name(request.subdomains.last)
    else
      Atreides::Site.default
    end
    session[:site_name] = @current_site.name
    @current_site
  end

  def post
    @post ||= Atreides::Post.find_by_id(params[:post_id]) ||
              Atreides::Post.new
  end

  def set_expires
    expires_in (last_modified+6.hours), :private => false, :public => true
    fresh_when(:etag => last_modified.utc.to_i, :last_modified => last_modified.utc, :public => true)
  end

  def last_modified
    case controller_name
    when 'admin_home'
      now = Time.now
      mod = now.hour%6
      last_modified = (now-mod.hours).change(:min => 0, :sec => 0, :usec => 0)
    else
      super
    end
  end

  def set_date
    @date ||= if params[:month] || params[:year]
      "1-#{params[:month]}-#{params[:year] || Date.today.year}".to_date rescue Date.today
    else
      Date.today
    end
  end
end

class Atreides::ApplicationController < ApplicationController
  helper 'atreides/application'

  before_filter :current_site
  before_filter :current_lang

  private

  def current_site
    # Use subdomain as key for site
    @current_site ||= Atreides::Site.find_by_name(request.subdomains.last) || Atreides::Site.default
    session[:site_name] = @current_site.name
    @current_site
  end

  def current_lang
    @current_lang = I18n.locale = current_site.lang if I18n.available_locales.include?(current_site.lang)
  end

  def end_of_association_chain
    assoc_name = params[:controller].split('/').last.strip.to_sym
    if current_site.respond_to?(assoc_name)
      current_site.send(assoc_name)
    else
      model_name.constantize
    end
  end

  def store_location
    session[:return_to] = request.fullpath
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def cache_key
    "#{request.url}/#{request.format.to_sym.to_s}/#{etag}/#{flash.to_s.gsub(/\W/,'')}"
  end

  def set_expires
    expires_in 30.seconds, :private => false, :public => true
  end

  def set_fresh_when
    if ActionController::Base.perform_caching and collection?
      return !stale?(:etag => etag, :last_modified => last_modified, :public => true)
    end
  end

  def etag
    last_modified.to_i
  end

  LAST_MODIFIED_CACHE_KEY = 'site_last_modified'

  def last_modified
    # Update the cache last-modified date
    set_last_modified(true) unless @last_modified ||= Rails.cache.read(LAST_MODIFIED_CACHE_KEY)
    @last_modified
  end

  def set_last_modified(force = false)
    # Don't update it unless forced to or the if the request is just a GET
    @last_modified = Time.now.utc
    Rails.cache.write(LAST_MODIFIED_CACHE_KEY, @last_modified) if force or !request.get?
  end

  def resource?
    respond_to?(:resource, true) and !resource.nil?
  end

  def collection?
    respond_to?(:collection, true) and !collection.nil? and !collection.empty?
  end

  def current_ability
    @current_ability ||= Atreides::Ability.new(current_user)
  end

  def atreides_setup?
    Atreides::User.admins.count > 0
  end

  def check_user_agent
    if request.user_agent =~ /(facebookexternalhit|curl)/i
      request.path_parameters.each do |k,v|
        params[k.to_sym] = v
      end
    end
  end
end

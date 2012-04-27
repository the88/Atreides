class Atreides::PublicController < Atreides::ApplicationController

  unloadable
  inherit_resources

  analytical :modules => Settings.analytics_backends, :use_session_store => true

  # caches_page # for making static sites
  # around_filter :cache

  # Set HTTP caching headers
  before_filter :set_expires
  before_filter :set_fresh_when
  before_filter :check_user_agent

  layout 'public'

  if Rails.env.production? # || Rails.env.staging?
    rescue_from 'Exception' do |exception|

      Rails.logger.info "Exception: #{exception}"
      Rails.logger.info exception.backtrace.join("\n")

      case exception.class.to_s
      when ActiveRecord::RecordNotFound.to_s
        render :template => 'atreides/errors/404', :layout => 'public', :status => 404
      else
        render :template => 'atreides/errors/500', :layout => 'public', :status => 500
      end
    end
  end

  protected

  def track_resource_analytics
    resource.tag_list.each { |tag|
      analytical.custom_event 'Tag', 'view', tag
    } if resource.respond_to?(:tag_list)

    analytical.custom_event 'Author', 'view', resource.author.email if resource.respond_to?(:author) && resource.author
  end

end
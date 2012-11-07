class Admin::Atreides::FacebookController < ApplicationController

  layout 'admin'

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


  def index
  end

  def update
    Atreides::FacebookUser.find_or_create(params)
    if Atreides::FacebookUser.authorize_page(Settings.facebook.page_id)
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  def destroy
    Atreides::FacebookUser.clear
    redirect_to("/admin/facebook")
  end


end
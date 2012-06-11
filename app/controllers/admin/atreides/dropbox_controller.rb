class Admin::Atreides::DropboxController < Atreides::ApplicationController
  layout 'admin', :except => :list
  include Admin::Atreides::DropboxHelper

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.info "AdminHomeController: CanCan::AccessDenied #{exception.inspect}, admin?: #{current_user && !current_user.admin?}; #{current_user.inspect}"
    if current_user && !current_user.admin?
      @message = exception.message
      render 'admin/common/access_denied'
    else
      redirect_to new_user_session_path, :notice => exception.message
    end
  end

  def unlink
    session[:dropbox_session] = nil
    redirect_to(request.referer.gsub(/\?.+/,"?add_content[]=photos"))
  end

  def list
    @dropbox_path = request[:path] || '/'
    ls = dropbox_client.metadata(@dropbox_path)['contents']
    @dirs = ls.select { |item| item['is_dir'] }
    @imgs = ls.select { |item| !item['is_dir'] && item['mime_type'] =~ /image/ }
    @imgs = @imgs.delete_if { |item| ['image/x-icon', 'image/x-photoshop'].include? item['mime_type'] }
  end

  def thumb
    @path = request[:path]
    headers['Content-Type'] = 'image/jpeg'
    self.response_body = dropbox_client.thumbnail(URI.escape(@path))
  end

  private

  def authorized?
    dropbox_session.authorized?
  end

end

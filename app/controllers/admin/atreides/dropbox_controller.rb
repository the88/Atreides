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
    dropbox_session.mode = :dropbox
    ls = dropbox_session.list(@dropbox_path)
    @dirs = ls.select { |item| item.directory? }
    @imgs = ls.select { |item| !item.directory? && item.mime_type =~ /image/ }
    @imgs = @imgs.delete_if { |item| ['image/x-icon', 'image/x-photoshop'].include? item.mime_type }
  end

  def thumb
    @path = request[:path]
    dropbox_session.mode = :dropbox
    headers['Content-Type'] = 'image/jpeg'
    self.response_body = proc do |resp, output|
      @res ||= begin puts "Requesting..."; dropbox_session.thumbnail(@path) end
      output.write @res
    end
  end

  private

  def authorized?
    session[:dropbox_session].present?
  end

end
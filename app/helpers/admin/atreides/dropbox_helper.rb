module Admin::Atreides::DropboxHelper
  def dropbox_session
    @dropbox_session ||= begin
      previous = session[:dropbox_session] if session[:dropbox_session].present?
      if previous && previous.authorized?
        previous
      elsif previous && params[:oauth_token]
        puts "Trying to authorize an existing dropbox session..."
        previous.get_access_token
        session[:dropbox_session] = previous # re-serialize the authenticated session
      else
        puts "Creating a new Dropbox session..."
        new_dropbox_session.tap do |dropbox_session|
          session[:dropbox_session] = dropbox_session
        end
      end
    end
  end

  def dropbox_client
    DropboxClient.new(dropbox_session, :dropbox) if dropbox_session.authorized?
  end

  def new_dropbox_session
    DropboxSession.new(Settings.dropbox.key, Settings.dropbox.secret).tap do |dropbox_session|
      begin
        dropbox_session.get_request_token
      rescue
      end
    end
  end

  def dropbox_authorize_link
    dropbox_session.get_authorize_url(request.url)
  end

  def basename(path)
    path.sub(@dropbox_path, '').sub(/^\//, '')
  end

  include Atreides::Extendable
end

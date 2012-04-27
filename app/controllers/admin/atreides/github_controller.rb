class Admin::Atreides::GithubController < Atreides::AdminController

  skip_before_filter :collection
  skip_before_filter :object

  def index
    @show_as_dash = true
    @issues = Atreides::Github.all(:state => params[:state] || "open")
    super do |wants|
      wants.html
      wants.js
    end
  end

  def show
    @issue = Atreides::Github.find(params[:id])
    @comments = @issue.comments
    super do |wants|
      wants.html
      wants.js
    end
  end

  def connect
    redirect_to(Atreides::Github.authorize_url)
  end

  def callback
    render :text => Atreides::Github.get_token(params[:code]).inspect
  rescue OAuth2::Error => e
    render :text => e.response.inspect
  end


end
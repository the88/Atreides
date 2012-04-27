class Admin::Atreides::PostsController < Atreides::AdminController
  helper 'admin/atreides/dropbox'

  def index
    show_as_dash
    super do |wants|
      wants.html { render :template => "admin/atreides/posts/index" }
      wants.js
    end
  end

  def new
    # In case we refer with additional types requested
    if params.key?(:add_content)
      params[:add_content].each do |type|
        if Atreides::ContentPart.content_types.include?(type)
          resource.parts.build(:content_type => type)
        end
      end
    end

    if Atreides::ContentPart.content_types.include?(params[:type])
      resource.parts.build(:content_type => params[:type])
    end
    super
  end

  def edit
    super do |wants|
      wants.html { render :template => "admin/atreides/posts/edit" }
    end
  end

  def create
    resource.author = current_user
    resource.last_editor = current_user
    super do |success, failure|
      success.html { redirect_to admin_posts_path }
      failure.html { render :template => "admin/atreides/posts/edit" }
    end
  end

  def update
    resource.last_editor = current_user
    super do |success, failure|
      success.html {
        if params[:post] and params[:post][:state] == "publish_now"
          flash[:notice] += " <b>Your post is now live!</b>"
        end
        redirect_to admin_posts_path
      }
    end
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_post_path resource }
    end
  end

  def destroy
    super do |wants|
      wants.html { redirect_to admin_posts_path }
    end
  end

  private

  def show_as_dash
    @show_as_dash ||= true
  end

  def resource
    @post ||= end_of_association_chain.find_by_slug(params[:id]) ||
              end_of_association_chain.find_by_id(params[:id])
  end

  def end_of_association_chain
    current_site.posts
  end

  def collection
    @posts ||= begin
      scope = end_of_association_chain.scoped
      scope = case params[:state]
        when "drafted"
          col = :updated_at
          scope.drafted
        else
          col = :published_at
          scope.published
      end
      if params[:month] and params[:year]
        @date = Date.parse("#{params[:year]}-#{params[:month]}-1")
        scope = scope.for_month @date, col
      end

      scope.order("#{col} desc, created_at desc")

      if params[:state] == "drafted"
        scope.all
      else
        scope.paginate(:page => (params[:page] || 1))
      end
    end
  end

  include Atreides::Extendable
end

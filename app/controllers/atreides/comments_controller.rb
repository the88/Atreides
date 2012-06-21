class Atreides::CommentsController < Atreides::PublicController
  helper "Atreides::Posts"
  before_filter :require_user, :only => [:create, :update]

  def index
    super do |wants|
      wants.html { head :not_found }
      wants.json { render :json => collection.to_json }
      wants.xml { render :xml => collection.to_xml }
    end
  end

  def create
    build_resource.request = request
    super do |success, failure|
      success.html { head :ok, :location => post_path(parent) }
      success.js
      failure.wants.html { head :error, :message => resource.errors.full_messages.to_sentence }
      failure.wants.js
    end
  end

  private

  def resource
    @comment ||= parent.comments.find params[:id]
  end

  def build_resource
    @comment ||= Comment.new params[:comment].update(:user => current_user, :commentable => parent)
  end

  def collection
    @comments ||= parent.comments.approved.paginate :page => params[:page]
  end

  def parent
    @parent ||= Atreides::Post.find_by_slug!(params[:post_id]) ||
                Atreides::Post.find(params[:post_id])
  end

  include Atreides::Extendable
end

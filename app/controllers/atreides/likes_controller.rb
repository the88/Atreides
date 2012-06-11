class Atreides::LikesController < Atreides::PublicController
  belongs_to :page, :post

  helper "Atreides::Posts"
  before_filter :require_user, :only => [:create]

  def index
    super do |wants|
      wants.html { head :not_found }
      wants.json { render :json => collection.to_json }
      wants.xml  { render :xml => collection.to_xml }
    end
  end

  def create
    super do |success, failure|
      success.html { head :ok, :location => post_path(parent) }
      success.js
      failure.wants.html { head :error, :message => "You already liked this" }
      failure.wants.js
    end
  end

  private

  def resource
    @like ||= parent.likes.find params[:id]
  end

  def build_resource
    @like ||= Like.new :user => current_user, :likeable => parent
  end

  def collection
    @likes ||= parent.likes.paginate :page => params[:page]
  end

  def parent
    @parent ||= Atreides::Post.find_by_slug(params[:post_id]) ||
                Atreides::Post.find(params[:post_id])
  end

  include Atreides::Extendable
end

class Admin::Atreides::TagsController < Atreides::AdminController
  respond_to :json

  def index
    respond_with(collection)
  end

  protected

  def collection
    if params[:term]
      term = "%#{params[:term]}%".downcase
      Atreides::Tag.where("LOWER(name) LIKE ?", term).all.map{|tag| tag.name.titleize}
    else
      []
    end
  end

  include Atreides::Extendable
end

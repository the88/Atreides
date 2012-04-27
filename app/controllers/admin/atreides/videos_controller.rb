class Admin::Atreides::VideosController < Atreides::AdminController

  helper "admin/atreides/posts"

  def create
    @video = resource = if params.key?(:Filedata)
      end_of_association_chain.new(:upload => params[:Filedata], :part => part)
    elsif params.key?(:video_url)
      end_of_association_chain.new(:url => params[:video_url], :part => part)
    end
    
    if @video.save
      respond_to do |wants|
        wants.js
        wants.html { render :status => :ok }
      end
    else
      logger.debug { "video errors: #{resource.errors.full_messages.to_sentence}\n#{resource.inspect}" }
      render :text => resource.errors.full_messages.to_sentence
    end
  end

  def reorder
    if params[:videos_list].is_a?(Array)
      i = 0
      params[:videos_list].each do |id|
        Atreides::Video.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end
  
  def destroy
    super do |wants|
      wants.js
    end
  end
  

  private

  def part
    @part ||= Atreides::ContentPart.find_by_id(params[:part_id])
  end

  def resource
    @resource = @video ||= end_of_association_chain.find(params[:id])
  end

  include Atreides::Extendable
end
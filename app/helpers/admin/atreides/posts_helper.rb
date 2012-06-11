module Admin::Atreides::PostsHelper

  def error_messages_for_post
    error_messages_for :post,
      :header_message => ttt(:validation_error_header, :model => @type.to_s),
      :message => ttt(:validation_error_message)
  end

  def edit_videos_for_assoc(resource, list_id = "videos_list", resource_type="post")
    if resource and resource.respond_to?(:videos)
      content_tag(:div, :id => "#{list_id}_container", :class => "videos-list media-list") do
        content_tag(:ul, :id => list_id) do
          resource.videos.map do |video|
            video_for_assoc(video, list_id, resource_type)
          end.join.html_safe
        end +
        sortable_element(list_id, :axis => "x")
      end
    end
  end

  def video_for_assoc(video, list_id, resource_type="post")
    # Each video
    width = 186
    height = 124
    embed = video.embedable?
    content_tag(:li, :id => video.dom_id(list_id)) do
      hidden_field_tag("#{resource_type}[parts_attributes][0][video_ids][]", video.id) +
      if video.new_record?
        link_to_function image_tag("atreides/admin/remove.png"), "$('##{video.dom_id(list_id)}').fadeOut(function(){ $(this).remove() })"
      else
        link_to(image_tag("atreides/admin/remove.png"), admin_video_path(video, :format => :js, :list_id => list_id), :remote => true, :'data-method' => :delete, :confirm => "Are you sure?")
      end +
      content_tag(:div, video.embed(:width => width, :height => height).html_safe, :id => video.dom_id) +
      text_area_tag("#{resource_type}[parts_attributes][0][videos_attributes][][caption]", video.caption) +
      hidden_field_tag("#{resource_type}[parts_attributes][0][videos_attributes][][id]", video.id)
    end
  end

  include Atreides::Extendable
end

module Admin::Atreides::PhotosHelper

  include Atreides::Extendable

  def photos_uploaders(part, photos_list_id, resource_type, part_uid)
    if Settings.dropbox.key && Settings.dropbox.secret
      render(:partial => 'admin/atreides/dropbox/uploader', :locals => { :part_id => (part.id || '-'), :list_id => photos_list_id }) +
      content_tag('span', 'or', :class => 'or') +
      multi_file_uploader(:url => send("admin_#{resource_type.to_s}_part_photos_path", :"#{resource_type.to_s}_id" => (part.contentable_id || '-'), :part_id => (part.id || '-'), :format => :js, :list_id => photos_list_id), :css_parent_class => "photos-upload", :dom_id => "multi_file_uploader_#{part_uid}")
    else
      multi_file_uploader(:url => send("admin_#{resource_type.to_s}_part_photos_path", :"#{resource_type.to_s}_id" => (part.contentable_id || '-'), :part_id => (part.id || '-'), :format => :js, :list_id => photos_list_id), :css_parent_class => "photos-upload", :dom_id => "multi_file_uploader_#{part_uid}")
    end
  end
end

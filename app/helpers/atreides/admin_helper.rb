module Atreides::AdminHelper

  def multi_file_uploader(opts = {})
    opts.reverse_merge!({
      :file_upload_limit => 50,
      :file_queue_limit => 0,
      :dom_id => "multi_file_uploader_#{Time.now.to_f.to_s.parameterize('_')}",
      :resource_type => "post"
    })

    url = opts[:url]
    css_parent_class = opts[:css_parent_class]
    dom_id = opts[:dom_id]
    css_class = "upload-btn"
    css_upload = "upload-progress"
    
    content_tag(:div, :id => dom_id, :class => "upload-container") do
      content_tag(:div, :class => "#{css_class}") do
        content_tag(:noscript, "Please enable JavaScript to use file uploader.")
      end +
      content_tag(:div, :class => css_upload, :style => "display:none") do
        content_tag(:span, "Uploading...")
      end
    end +
    javascript_tag(%Q{
      $(function() {
        new qq.FileUploader({
          element: $('##{dom_id} .#{css_class}')[0],
          action: '#{url}',
          allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
          minSizeLimit: 100,
          sizeLimit: #{10.megabytes},
          params: {
            resource_type: '#{opts[:resource_type]}',
            post_type: 'photos'
          },
          debug: #{Rails.env.development?},
          onSubmit: function(id, fileName){
            $('##{dom_id} .#{css_upload}').progressbar()
            $('##{dom_id} .#{css_upload}').show()
            $('##{dom_id} .#{css_upload} span').text('Uploading...')
          },
          onProgress: function(id, fileName, loaded, total){
            $('##{dom_id} .#{css_upload}').show()
            $('##{dom_id} .#{css_upload} span').text('Uploading file '+ fileName)
            // console.log('bytes_complete: '+loaded)
            // console.log('total_bytes: '+total)
            // console.log('progress: '+(loaded/total))
            $('##{dom_id} .#{css_upload}').progressbar('value',((loaded/total)*100))
          },
          onComplete: function(id, fileName, responseJSON){
            // console.log('responseJSON: '+responseJSON)
            $('##{dom_id} .#{css_upload}').hide()
            $('##{dom_id} .upload-progress span').text('Awaiting response...')
          },
          onCancel: function(id, fileName){
            $('##{dom_id} .#{css_upload}').hide()
            $('##{dom_id} .upload-progress span').text('Canceled...')
          },
          showMessage: function(message){
            $('##{dom_id} .upload-progress span').text('')
            // message
            // $('#flash').html(message).addClass('error flash').show()
          }
        })
      })
    })
  end

  def add_inline_photo(url)
    css_flash = "add_photo_flash"
    css_link = ".add-inline-photo a"
    css_loading = ".add-inline-photo img"
    link_to_function(tt(:'.add_inline_photo'), "$('##{css_flash}').swfupload('selectFile')") +
    image_tag("atreides/loading.gif", :style => "display:none") +
    content_tag(:div, "", :id => css_flash) do
      content_tag(:span, "", :id => "spanButtonPlaceholder")
    end +
    javascript_tag("
    $(document).ready(function() {
        $('##{css_flash}').swfupload({
            upload_url: '#{url}',    // Relative to the SWF file (or you can use absolute paths)
            post_params: {
              '#{session_key}': '#{cookies[session_key]}',
              'authenticity_token': '#{form_authenticity_token}',
            },
            // File Upload Settings
            file_size_limit : '102400', // 100MB
            file_types : '*.jpg;*.jpeg;*.png;*.gif',
            file_types_description : 'Image Files',
            file_upload_limit : '0',
            file_queue_limit : '1',
            // Button Settings
            //button_image_url : '#{image_path('atreides/blank.gif')}', // Relative to the SWF file
            button_placeholder_id : 'spanButtonPlaceholder',
            //button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
            button_cursor: 'pointer',
            button_width: $('##{css_flash}').width(),
            button_height: $('##{css_flash}').height(),
            // Flash Settings
            flash_url : '#{asset_path('atreides/swfupload.swf')}'
        });
        // assign our event handlers
        $('##{css_flash}')
            .bind('fileQueued', function(event, file){
              $('#{css_link}').hide()
              $('#{css_loading}').show()
              $(this).swfupload('startUpload');
            })
            .bind('uploadSuccess',function(event, file, server_data, response) {
              $('#{css_link}').show()
              $('#{css_loading}').hide()
              if (response) {
                jQuery.globalEval(server_data)
              }
            })
            .bind('uploadError',function(event, file, error, message) {
              // console.log('uploadError')
              $('#flash').html('Error from server trying to upload image: '+message).addClass('error flash').show()
            })
        });
    ")  
  end

  def edit_photos_for_assoc(object, list_id = nil)
    if object and object.respond_to?(:photos) and object.respond_to?(:dom_id)
      list_id ||= object.dom_id("photos_list")
      content_tag(:div, :id => "#{list_id}_container", :class => "media-list photos-list") do
        content_tag(:ul, :id => list_id) do
          object.photos.map do |photo|
            # Each photo
            photo_for_assoc(photo, object.class.to_s.downcase, list_id)
          end.join.html_safe
        end +
        edit_photos_sortable(list_id)
      end
    end
  end

  def photo_for_assoc(photo, object, list_id = "photos_list")
    if defined?(Atreides::Feature) and object.is_a?(Atreides::Feature)
      feature_photo_for_assoc(photo, object, list_id)
    else
      post_photo_for_assoc(photo, object, list_id)
    end
  end

  def post_photo_for_assoc(photo, object, list_id = "photos_list", thumb_size = :thumb)
    param_name = (object.is_a?(String) ? object : object.class.to_s).demodulize.downcase
    content_tag(:li, :id => photo.dom_id(list_id), :class => "post-photo-for-assoc") do
      link_to(image_tag("atreides/admin/remove.png"), admin_photo_path(photo, :format => :js, :list_id => list_id), :remote => true, :method => :delete, :confirm => "Are you absolutely sure?") +
      image_tag(photo.image.url(thumb_size), :class => "photo-thumb", :size => photo.size(thumb_size).values.join('x')) +
      hidden_field_tag("post[parts_attributes][0][photo_ids][]", photo.id) +
      text_area_tag("post[parts_attributes][0][photos_attributes][][caption]", photo.caption) +
      hidden_field_tag("post[parts_attributes][0][photos_attributes][][id]", photo.id) +
      hidden_field_tag("post[parts_attributes][0][photos_attributes][][display_order]", photo.display_order)
    end
  end

  def feature_photo_for_assoc(photo, object, list_id = "photos_list", thumb_size = :thumb)
    attr_name  = 'photo_attributes'
    
    content_tag(:li, :id => (photo ? photo.dom_id(list_id) : nil), :class => "feature-photo-for-assoc") do
      # Do full photo delete if used just by feature, otherwise remove from feature
      if photo
        image_tag(photo.image.url(thumb_size), :class => "photo-thumb", :size => photo.size(thumb_size).values.join('x')) + 
        hidden_field_tag("#{object.class.to_s.downcase}[#{attr_name}][id]", photo.id) +
        hidden_field_tag("#{object.class.to_s.downcase}[#{attr_name}][display_order]", photo.display_order)
      end
    end
  end

  def edit_photos_sortable(list_id = "photos_list")
    sortable_element("##{list_id}", 
      # :url => reorder_admin_photos_path(:format => :js), 
      :axis => false,
      :update => "function() { $('##{list_id} input[id$=display_order]').each(function(i, el){ el.value = i }) }"
    )
  end

  def calendar_day(day, posts)
    content_tag(:span, day.mday, :class => "mday #{'future' if day>Date.today}") +
    if (p = posts.detect{|b| b.published_at.mday==day.mday })
      link_to(image_tag(p.image.url(:thumb)), admin_post_path(p))
    else
      ""
    end
  end

  def sidebar_new_content_link
    name = controller.controller_name.split('/').last
    content_type = case name
    when "pages", "posts", "users"
      controller_name.singularize
    when "orders", "products"
      "product"
    when "features"
      "feature"
    else
      name.to_s.singularize
    end
    link_to ttc("new_#{content_type}"), admin_new_content_path(content_type) if content_type
  end

  def ga_visitors_graph(results)
    content_tag(:div, "", :id => "ga_visitors", :class => "graph") +
    javascript_tag("
    $(document).ready(function() {
      
    })
    ")
  end

  def link_to_preview
    obj = params[:controller]=~/pages/ ? 'page' : 'post'
    
    link_to_function(ttt(:preview), %Q{
      $('iframe.preview-pane').dialog({ 
        modal: true,  
        width:960,  
        height:500, 
        open: function() {
          $(this).css('width',960)
          var form = $('form##{obj}_edit, form##{obj}_new').
            clone().
            attr('id','#{obj}_preview_form').
            attr('action','#{send("preview_#{obj}_path")}').
            attr('method','post').
            attr('target','#{obj}_preview').
            hide().
            appendTo($('#body'));
          form.submit().remove();
        } })
    }, :class => "preview") +
    content_tag(:iframe, "", :id => "#{obj}_preview", :class => "preview-pane", :src => "about:blank", :width => 1, :height => 1, :name => "#{obj}_preview")
  end
  
  def seconds_from_now(datetime)
    Time.now.to_i - Time.at(datetime.to_i).to_i
  end

  include Atreides::Extendable
end

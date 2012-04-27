# Methods added to this helper will be available to all templates in the application.
module Atreides::ApplicationHelper

  def facebook_meta_tags

    return unless page_object

    title = Settings.app_name + " - #{page_title}"

    str  = tag(:meta, :name => "title", :content => title) + "\n"
    str += tag(:meta, :name => "description", :content => page_description) + "\n"

    str += tag(:meta, :property => "og:title", :content => title) + "\n"
    str += tag(:meta, :property => "og:description", :content => page_description) + "\n"
    str += tag(:meta, :property => "og:url", :content => request.url) + "\n"
    str += tag(:meta, :property => "og:site_name", :content => Settings.app_name) + "\n"
    str += tag(:meta, :property => "og:type", :content => "article") + "\n"
    
    return str unless page_object.respond_to?(:post_type)
    
    str += case page_object.post_type.to_s
    when "video"
      unless page_object.videos.empty?
        v = page_object.videos.first
        tag(:link, :rel => "video_src", :href => v.embed_url, :title => title) + "\n" +
        tag(:meta, :rel => "video_height", :content => v.height) + "\n" +
        tag(:meta, :rel => "video_width", :content => v.width) + "\n" +
        tag(:meta, :rel => "video_type", :content => "application/x-shockwave-flash") + "\n" +
        tag(:link, :rel => "image_src", :href => v.thumb_url, :title => title) + "\n" +
        tag(:meta, :property => "og:video", :content => v.embed_url) + "\n" +
        tag(:meta, :property => "og:video:height", :content => v.height) + "\n" +
        tag(:meta, :property => "og:video:width", :content => v.width) + "\n" +
        tag(:meta, :property => "og:video:type", :content => "application/x-shockwave-flash") + "\n" +
        tag(:meta, :property => "og:image", :content => v.thumb_url)
      end
    else
      if page_object.thumbnail
        tag(:link, :rel => "image_src", :href => page_object.thumbnail, :title => title) + "\n" +
        tag(:meta, :name => "medium", :content => "image") + "\n" +
        tag(:meta, :property => "og:image", :content => page_object.thumbnail) + "\n"
      end
    end
    str.html_safe
  end
  
  def page_title
    return "" if page_object.nil?

    page_object.title
  end

  def page_description
    return "" if page_object.nil?
    truncate_words(strip_tags(page_object.body), :length => 20, :omission => "...")
  end

  def page_object
    page_object ||= @post || @page
    page_object ||= @posts.first if @posts
    page_object
  end

  #
  # Common
  #
  def flash_messages
    return unless messages = flash.keys.select{|k| [:notice, :message, :warning, :error].include?(k)}
    content_tag(:div, :id => "flash") do
      messages.map do |type|
        content_tag :div, :id => "flash-#{type.to_s}", :class => "flash #{type.to_s}" do
          content_tag :span, message_for_item(flash[type], flash["#{type}_item".to_sym]).html_safe
        end
      end.join.html_safe
    end
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message
    end
  end

  def session_key
    @session_key ||= Rails.application.config.session_options[:key]
  end

  def link_current_block
    @link_current_block ||= Proc.new { |name| content_tag(:span, name) }
  end

  def body_classes
    con = params[:controller].split('/').last.strip
    act = params[:action].strip
    id  = resource ? resource.to_param : nil
    "#{con} #{con}-#{act} #{id} #{@body_classes.to_s}"
  end

  def truncate_words(txt, ops = {})
    ops.reverse_merge({
      :length => 100, 
      :omission   => "..."
    })
    words = txt.to_s.split()
    words[0..(ops[:length]-1)].join(' ').to_s + (words.length > ops[:length] ? ops[:omission] : '').to_s
  end

  #
  # ScriptaculousHelper overrides for jQuery
  #
  def sortable_element_js(element_id, options = {}) #:nodoc:
    # Make AJAX callback request if URL provided
    if options.key?(:url)
      options[:data] = %($(#{ActiveSupport::JSON.encode(element_id)}).sortable('serialize'))
      options[:update] = "function(){" + remote_function(options) + "}"
      options.delete(:url)
      options.delete(:data)
    end
    [:axis].each {|k| options[k] = "'#{options[k]}'" }

    %($(#{ActiveSupport::JSON.encode(element_id)}).sortable(#{options_for_javascript(options)});)
  end
  
  def remote_function(options)
    opts = {
      :type     => options[:type] || options[:method] || 'post',
      :dataType => options[:dataType] || 'script',
      :url      => options[:url] || url_for(params)
    }
    opts.each_pair{|k,v| opts[k] = "'#{v}'" }
    opts[:data] = options[:data] if options.key?(:data)
    
    [:success, :complete, :beforeSend, :error].each do |k|
      opts[k] = "function(){" + options[k] + "}" if options.key?(k)
    end

    %($.ajax(#{options_for_javascript(opts)});)
  end

  #
  # Forms and Lists
  #
  def col_to_field(col)
    case col.type
    when :text
      :text_area
    when :boolean
      :check_box
    when :date
      :date_select
    when :datetime, :time
      :datetime_select
    else
      :text_field
    end
  end

  def col_to_class_name(col)
    case col.type
    when :text
      :textarea
    when :boolean
      :checkbox
    when :date, :datetime, :time
      :select
    else
      :text
    end
  end

  def sort_col(col)
    col_sym = col.class.to_s.downcase.to_sym rescue nil
    case col_sym
    when :datetime, :time
      "date-iso"
    else
      "text"
    end
  end
  
  def action_link(action, record, record_name, final_options = {})
    url = case action.to_sym
    when :show, :destroy, :update
      "#{record_name}_path"
    when :edit
      "edit_#{record_name}_path"
    when :new
      "new_#{record_name}_path"
    else
      "#{action}_#{record_name}_path"
    end

    options = case action.to_sym
    when :destroy
      {:confirm => 'Are you sure?', :method => :delete}
    when :moderate
      {:confirm => 'Are you sure?', :method => :put }
    end
    options ||= {}

    link_to action.capitalize, send(url, record), {:class => action}.merge(options).merge(final_options)
  end

  include Atreides::Extendable
end
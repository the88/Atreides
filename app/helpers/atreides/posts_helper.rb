module Atreides::PostsHelper

  def like_label(post)
    count = post.likes.count
    str = count.zero? ? "like this?" : "#{pluralize(count, 'people')} like this"
    content_tag :div, link_to(str, post_likes_path(post), :remote => true), :id => post.dom_id('like_label')
  end

  def post_item(post)
    content_tag(:div, :class => "post-title") do
      link_to_unless_current(post.title? ? post.title : post.published_at.to_s(:date_ordinal), post_path(post, post.slug))
    end +
    post.parts.map do |part|
      case part.content_type.to_sym
      when :photos
        photos_part(part)
      when :videos
        videos_part(part)
      when :text
        text_part(part)
      end
    end.join.html_safe +
    # Tags
    post_action_links(post)
  end

  def photos_part(part)
    contentable = part.contentable
    obj_type = contentable.class.to_s.demodulize.downcase
    # Rejection cases
    return unless %w(post product page).include?(obj_type.to_s)
    return if part.photos.empty?

    detail_path = send("#{obj_type}_path", contentable.to_param, contentable.slug)
    image_size = :list # Is this needed? -> detail_page? ? :medium : :list
    thumb_panes = detail_page? ? 6 : 4
    thumb_photos = part.photos[(detail_page? ? 0 : 1)..(detail_page? ? part.photos.count : thumb_panes+1)]
    is_gallery = (part.respond_to?(:display_type) and part.display_type? and part.display_type.gallery?)

    content_tag(:div, :class => "photos-slideshow") do
      content_tag(:div, :class => (detail_page? && is_gallery) ? "slideshow" : "stacked-photos") do
        photos = detail_page? ? part.photos : [part.photos.first]
        photos.map do |f|
          display = (f==part.photos.first || !is_gallery) ? "block" : "none"
          dom_id = f.dom_id
          # Make link
          content_tag(:div, :id => dom_id, :class => "slide", :style => "display:#{display}") do
            s = f.size(image_size) rescue {}
            link_to(image_tag(f.image.url(image_size), :size => [s[:width], s[:height]].join('x')), send("#{obj_type}_path", contentable.to_param, contentable.slug, :anchor => dom_id), :name => dom_id) +
            content_tag(:p, (f.caption? ? f.caption : " "), :class => "photo-caption")
          end
        end.join.html_safe
      end +

      # Only show thumbs on details page
      if thumb_photos.size > 1 && (!detail_page? || is_gallery)
        content_tag(:div, :class => "slideshow-controls") do
          content_tag(:ul, :class => "slideshow-controls-container #{'carousel' if detail_page? && thumb_photos.size > thumb_panes}") do
            thumb_photos.map do |p|
              content_tag(:li) do
                link_to(image_tag(p.image.url(:thumb), :size => "95x95"), send("#{obj_type}_path", contentable, contentable.slug, :anchor => p.dom_id), :class => (p==thumb_photos.last ? "last" : ""))
              end
            end.join.html_safe
          end
        end
      end.to_s

    end +
    content_tag(:div, "", :class => "clear")
  end

  def text_part(part)
    post  = part.contentable
    parts = part.body.to_s.split('<!--more-->')

    if parts.size > 1 && controller.action_name!='show'
      parts.first.to_s + "... " + link_to("Continue reading #{post.title}.", post_path(post, post.slug))
    else
      part.body.to_s
    end.html_safe
  end

  def videos_part(part)
    post  = part.contentable

    return "No videos found" if part.videos.empty?
    part.videos.map do |video|
      # Details and list sizes are different
      width = 630
      height = ((width.to_f/video.width) * video.height).to_i
      content_tag(:div, video.embed(:width => width, :height => height).html_safe, :id => video.dom_id, :class => "post-video")
    end.join.html_safe
  end

  def post_action_links(post)
    content_tag(:div, :class => "post-links clear") do
      content_tag(:ul) do
        lnks = [
          link_to("+ Share", post_url(post, post.slug), :class => "share", :title => "#{Settings.app_name} - #{post.title}"),
          post.tag_list.map{|t| link_to(t.titleize, tagged_posts_path(t), :class => "tag") }
        ].flatten
        lnks.map{|lnk| content_tag(:li, lnk) }.join.html_safe
      end
    end
  end

  def detail_page?
    return true if %w(atom rss application/atom+xml application/rss+xml).include?(request.format.to_s)

    case controller.controller_name.to_sym
    when :contributors
      false
    else
      %w(show feeds).include?(controller.action_name)
    end
  end

  include Atreides::Extendable
end

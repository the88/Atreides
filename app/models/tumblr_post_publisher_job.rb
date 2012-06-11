# Class to aid in the publishing of posts to Tumblr.
# This is typically used with Delayed Job in a background process
# Eg:
#  Delayed::Job.enqueue(TumblrPostPublisherJob.new(post.id))
#
#
# It requires that there is a 'tumblr' section in your settings.yml config file
#
TumblrPostPublisherJob = Struct.new(:post_id)
class TumblrPostPublisherJob

  require 'tumblr'

  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.domain

  # Executes the job. This authorizes the client with Tumblr using settings.yml configuration
  # It will update the post object with the posts tumblr_id on success
  # @return [Int] the tumblr id of the newly created post
  def perform

    return false unless Settings.has_key?('tumblr')

    # Find objects
    post = Atreides::Post.find(post_id)

    # Abort if already posted
    return if post.tumblr_id?

    # Common part
    tumblr = {
      :slug => post.slug
    }

    add_link_for_more = false
    part = posts.first

    case part.content_type
    when "text"
      tumblr.merge!({
        :type       => "regular",
        :title      => part.title,
        :body       => part.body
      })
    when "videos"
      tumblr.merge!({
        :type     => "video",
        :embed    => part.videos.first.url,
        :caption  => part.videos.first.caption
      })
      add_link_for_more = (part.videos.count > 1)
    when "photos"
      tumblr.merge!({
        :type     => "photo",
        :source   => part.photos.first.image.url,
        :caption  => part.photos.first.caption
      })
      add_link_for_more = (part.photos.count > 1)
    end

    link = post_url(post, :slug => post.slug)

    tumblr[:caption] += "<br />View more <a href='#{link}'>here</a>" if add_link_for_more

    # Authentication
    user = Tumblr::User.new(Settings.tumblr.email, Settings.tumblr.pass, false)

    tumblr_id = Tumblr::Post.create(user, tumblr)

    # Tumblr it!
    post.update_tumblr_id(tumblr_id)
  end

  include Atreides::Extendable
end

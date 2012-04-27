# Class to aid in the publishing of posts to Facebook. 
# This is typically used with Delayed Job in a background process
# Eg:
#  Delayed::Job.enqueue(TumblrPostPublisherJob.new(post.id))
# 
# It requires that there is a 'tumblr' section in your settings.yml config file
# 
FbPostPublisherJob = Struct.new(:post_id)
class FbPostPublisherJob

  return false unless Settings.has_key?('facebook')

  require 'uri'
  require 'yaml'
  require 'mini_fb'
  
  include Rails.application.routes.url_helpers
  default_url_options[:host] = Settings.domain
  
  # Executes the job. This authorizes the client with Facebook using settings.yml configuration
  # It will update the post object with the posts facebook_id on success
  # @return [Int] the tumblr id of the newly created post
  def perform
    post = Atreides::Post.find post_id
    
    # Abort if already posted
    return if post.facebook_id?

    url  = post_url(:id => post.to_param, :slug => post.slug.to_s)
    msg  = !post.social_msg.blank? ? post.social_msg : post.title.truncate(140)
    body = post.body.gsub(%r{</?[^>]+?>}, '').gsub(/&nbsp;/,' ').truncate(420)
    default_img_path = "#{root_url}images/fb_share.png"
    part = post.parts.first
    img_url = if part.content_type.video? && !part.videos.empty?
      part.videos.first.thumb_url rescue default_img_path
    else
      uri = URI.parse(url)
      !part.photos.empty? ? "#{uri.scheme}://#{uri.host}#{part.photos.first.image.url(:thumb)}" : default_img_path
    end

    resp = facebook.post("/me/feed", {
      :message => msg,
      :name => "#{Settings.app_name} - #{post.title.truncate(420)}",
      :from => Settings.facebook.page_id, # Post as the page
      :link => url,
      :source => (!post.first_video.nil?) ? post.first_video.url : img_url,
      :caption => body, 
      :description => Settings.app_name,
      :picture => img_url,
      :likes => true
    })

    # needs checking vs. returned facebook json object
    if resp.keys.include?('id')
      ids = resp["id"].split('_')
      fbid = ids[0]
      story_fbid = ids[1]
      post.update_facebook_id(fbid.to_i)
    end

  end

  protected

  # Return a facebook client object
  def facebook
    MiniFB.disable_logging
    @facebook ||= MiniFB::OAuthSession.new(Settings.facebook.page_token)
  end

  include Atreides::Extendable
end

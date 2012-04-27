Factory.define :video, :class => Atreides::Video do |video|
  video.sequence(:caption)  { |n| "Factory video #{n}" }
  video.url                 "http://youtu.be/0LEXAaBhk0M"
  # video.vimeo_id            "url4test"
  video.created_at          5.minutes.ago
  video.updated_at          5.minutes.ago
  video.sequence(:display_order)  { |n| n }
  video.embed               ""
  video.width               360
  video.height              240
  video.thumb_url           ""
end
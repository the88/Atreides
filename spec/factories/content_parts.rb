Factory.define :content_part_text, :class => Atreides::ContentPart do |part|
  part.content_type     "text"
  part.body             "<p>I'm a simple body</p>"
  part.sequence(:display_order) { |n| n }
end

Factory.define :content_part_photos, :class => Atreides::ContentPart do |part|
  part.content_type     "photos"
  part.photos {|p| [p.association(:photo)]}
  part.sequence(:display_order) { |n| n }
end

Factory.define :content_part_videos, :class => Atreides::ContentPart do |part|
  part.content_type     "videos"
  part.videos {|v| [v.association(:video)]}
  part.sequence(:display_order) { |n| n }
end

Factory.define :photo, :class => Atreides::Photo do |photo|
  photo.sequence(:caption)        { |n| "Factory photo #{n}" }
  photo.image_file_name           "factory_test_file.png"
  photo.image_content_type        "image/png"
  photo.image_file_size           512
  photo.image_updated_at          5.minutes.ago
  photo.sizes                     "120x120"
  photo.created_at                5.minutes.ago
  photo.updated_at                5.minutes.ago
  photo.sequence(:display_order)  { |n| n }
end

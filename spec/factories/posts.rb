Factory.define :post, :class => Atreides::Post do |post|
  post.state            "published"
  post.sequence(:title) { |n| "Factory post #{n}" }
  post.published_at     1.minute.ago.to_s
  post.site_id          Atreides::Site.default.id
  post.parts {|p| [p.association(:content_part_text)]}
  post.location_list    ["blog"]
  post.tag_list         ['test_tag', 'other_tag']
  post.author           { |author| author.association :user}
  post.tw_me            false
  post.fb_me            true
end

Factory.define :pending_post, :parent => :post, :class => Atreides::Post do |post|
  post.state            "pending"
end

Factory.define :drafted_post, :parent => :post, :class => Atreides::Post do |post|
  post.state            "drafted"
end

Factory.define :published_post, :parent => :post, :class => Atreides::Post do |post|
  post.state            "published"
  post.published_at 1.day.ago
end

Factory.define :post_to_be_published_now, :parent => :post, :class => Atreides::Post do |post|
  post.state            "publish_now"
end

Factory.define :photos_post, :class => Atreides::Post do |post|
  post.sequence(:title) { |n| "Factory photos post #{n}" }
  post.parts {|p| [p.association(:content_part_photos)]}
end

Factory.define :videos_post, :class => Atreides::Post do |post|
  post.sequence(:title) { |n| "Factory videos post #{n}" }
  post.parts {|p| [p.association(:content_part_videos)]}
end
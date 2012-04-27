time_fmt = "%Y-%m-%dT%H:%M:%SZ"
xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title Settings.app_name
    xml.description Settings.app_name
    xml.link root_url
    
    unless !collection 
      collection.each do |post|
        xml.item do
          xml.title post.title
          xml.description post_item(post)
          xml.pubDate post.published_at.to_s(:rfc822)
          xml.link post_url(post, post.slug)
          xml.guid post_url(post, post.slug)
        end
      end
    end
  end
end
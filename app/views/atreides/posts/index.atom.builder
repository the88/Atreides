# app/views/home/index.atom.builder
time_fmt = "%Y-%m-%dT%H:%M:%SZ"
time = Time.now
atom_feed :language => 'en-US' do |feed|
  feed.title(Settings.app_name)
  feed.link(:href => root_url)
  unless !collection
    feed.updated(collection.map(&:updated_at).max)
    i = 0
    collection.each do |post|
      feed.entry(post, :id => "tag:#{Settings.domain},#{time.year}:#{post.id.to_s}", :url => post_url(post, post.slug)) do |entry|
        entry.title(post.title)
        entry.content(post_item(post), :type => 'html')
        entry.author do |author| 
          author.name(Settings.app_name)
        end
      end
    end
  end
end



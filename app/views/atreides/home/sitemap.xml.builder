xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # begin
    @posts.each do |post|
      xml.url do
        xml.loc post_url(post, post.slug)
        xml.lastmod post.updated_at.to_date
      end
    end

    @countdowns.each do |entry|
      xml.url do
        xml.loc show_countdown_url(entry, entry.slug)
        xml.lastmod entry.updated_at.to_date
      end
    end

    @pages.each do |page|
      xml.url do
        xml.loc page_url(page)
        xml.lastmod page.updated_at.to_date
      end
    end

    6.times do |i|
      xml.url do
        xml.loc url_for(root_url + "month/" + Date::MONTHNAMES[i+1].downcase)
      end
    end

  # rescue Exception => exc
  #   logger.error "Error creating sitemap months: #{exc}"
  #   logger.error exc.backtrace
  # end
end
Given /^the following posts:$/ do |posts|
  Atreides::Post.create!(posts.hashes)
end

Then /^show me the posts$/ do
  puts Hirb::View.render_output Atreides::Post.all
end


When /^I delete the (\d+)(?:st|nd|rd|th) post$/ do |pos|
  visit posts_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following posts:$/ do |expected|
  expected.diff!(tableish('table tr', 'td,th'))
end


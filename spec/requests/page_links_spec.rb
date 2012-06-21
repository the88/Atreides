require_relative '../spec_helper.rb'

describe "PagesLinks" do

  before do
    @page = Factory.create(:published_page, :site => Atreides::Site.default)
  end

  it "should show page at /:page_slug" do
    get "/#{@page.slug}"
    response.should be_success
  end

end

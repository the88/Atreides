require_relative '../spec_helper.rb'

describe "Photos" do

  before do
    @post = Factory.create(:photos_post)
  end
  
  @selenium
  it "should support the photo upload", :js => true do
    url = edit_admin_post_path(@post)
    visit url
  end
end
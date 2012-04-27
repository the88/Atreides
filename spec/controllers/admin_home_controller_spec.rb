require 'spec_helper'

describe Atreides::AdminHomeController do
  
  before(:each) do
    @user = Factory(:user_admin)
    @site_www = Atreides::Site.default
    @site_blog = Factory(:site, :lang => :fr)
    @post_www = Factory(:post, :site => @site_www)
    @post_blog = Factory(:post, :site => @site_blog)
    sign_in @user
  end
  
  describe "POST /admin/switch_site" do
    
    it "switches current site" do
      # Go to admin archives with default site
      @site_www.lang.should eql(:en)
      get :index
      response.should be_success
      assigns(:current_site).should eql(@site_www)
      assigns(:current_lang).should eql(:en)
      
      # Switch to another site
      post :switch_site, :site => @site_blog.name
      response.should be_redirect
      
      # Current site has changed and posts are different
      @site_blog.lang.should eql(:fr)
      get :index
      response.should be_success
      
      assigns(:current_site).should eql(@site_blog)
      assigns(:current_lang).should eql(:fr)
      
    end
    
  end
  
  describe "GET /admin/search" do
    
    it "returns search results" do
      get :search, :search => @post_www.title.split(/\s+/)[1]
      response.should be_success
    end
    
  end
  
end
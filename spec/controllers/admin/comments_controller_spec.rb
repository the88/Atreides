require 'spec_helper'
require 'hashie'
require 'rash'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe Admin::Atreides::CommentsController do

  before do
    @user = Factory(:user_admin)
    @site_www = Atreides::Site.default
  end
  
  describe "GET index" do
    before do
      listPosts = fixture_file('listPosts.json')
      forum = Disqussion::Forums.new
      forum.stub!(:listPosts => Hashie::Rash.new(:code => 0, :response => listPosts))
      mock('Disqussion::Forums').stub!(:new => forum)
    end
    
    it "assigns all comments as @comments" do
      get :index
      assigns(:collection).should_not be_empty
    end

    # describe "drafted comments" do
    #   before do
    #     get :index, :state => "drafted", :month => Date.today.month, :year => Date.today.year
    #   end
    # 
    #   it "should assigns only drafted comments as @comments" do
    #     assigns(:comments).empty?.should_not be true
    #     assigns(:comments).all? { |page| page.drafted?.should be true }
    #   end
    # end
  end
  
  describe "PUT update_many" do
    it "send approve updates to Disqus" do
      Disqussion::Posts.stub!(:new).and_return do |*args|
        a = Disqussion::Posts.call(*args)
        a.should_receive(:approve).with(['1', '2'])
      end
      
      put :update_many, :comment_ids => ['1', '2'], :comment_action => 'approve'
    end
    
    it "send approve updates to Disqus" do

      sign_in @user

      Disqussion::Posts.stub!(:new).and_return do |*args|
        a = Disqussion::Posts.call(*args)
        a.should_receive(:spam).with(['1', '2'])
      end
      
      put :update_many, :comment_ids => ['1', '2'], :comment_action => 'mark-spam'
      response.should redirect_to admin_comments_path
    end
  end
  
  describe "DELETE delete_many" do
    it "send delete command to Disqus" do

      sign_in @user

      put :delete_many, :comment_ids => ['1', '2']
      mock(Disqussion::Posts.new).should_receive(:remove).with(['1', '2'])
      response.should redirect_to admin_comments_path
    end
  end
end
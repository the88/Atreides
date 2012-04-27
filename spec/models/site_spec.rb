require 'spec_helper'

describe Atreides::Site do
  describe "validation" do
    before do
      @site = Factory.create(:site)
    end

    it "should be valid and create a site" do
      site = Atreides::Site.new(:name => "www-2")
      site.valid?.should eql(true)
      site.save.should eql(true)
      site.lang.should eql(I18n.locale)
    end

    it "should not be valid with non-unique name" do
      site = Atreides::Site.new(:name => @site.name)
      site.save.should eql(false)
      site.valid?.should eql(false)
      site.errors[:name].nil?.should eql(false)
    end

    it "should not be valid without a name" do
      site = Atreides::Site.new()
      site.save.should eql(false)
      site.valid?.should eql(false)
      site.errors[:name].nil?.should eql(false)
    end

    it "should not be valid with an unknown lang" do
      site = Atreides::Site.new(:lang => :jp)
      site.save.should eql(false)
      site.valid?.should eql(false)
      site.errors[:lang].nil?.should eql(false)
    end
  end
  
  describe "site scoping" do
    before do
      @site_www = Atreides::Site.default
      @post_www = Factory.create(:post, :site => @site_www)
      @page_www = Factory.create(:page, :site => @site_www)
      @feature_www = Factory.create(:feature, :site => @site_www)

      @site_blog = Factory.create(:site)
      @post_blog = Factory.create(:post, :site => @site_blog)
      @page_blog = Factory.create(:page, :site => @site_blog)
      @feature_blog = Factory.create(:feature, :site => @site_blog)
    end

    it "should include different posts for different sites" do

      # Not empty?
      [@site_www.posts, @site_www.pages, @site_www.features, @site_blog.posts, @site_blog.pages, @site_blog.features].each do |coll|
        coll.empty?.should eql(false)
      end

      # Positives
      @site_blog.posts.include?(@post_blog).should eql(true)
      @site_blog.pages.include?(@page_blog).should eql(true)
      @site_blog.features.include?(@feature_blog).should eql(true)

      @site_www.posts.include?(@post_www).should eql(true)
      @site_www.pages.include?(@page_www).should eql(true)
      @site_www.features.include?(@feature_www).should eql(true)
      
      # Negatives
      @site_blog.posts.include?(@post_www).should eql(false)
      @site_blog.pages.include?(@page_www).should eql(false)
      @site_blog.features.include?(@feature_www).should eql(false)
      
      @site_www.posts.include?(@post_blog).should eql(false)
      @site_www.pages.include?(@page_blog).should eql(false)
      @site_www.features.include?(@feature_blog).should eql(false)

    end
  end

end
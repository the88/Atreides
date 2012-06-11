require 'spec_helper'

describe Atreides::Post do
  describe "validation" do
    before do
    end

    it "should be valid and create a post without parts" do
      post = Atreides::Post.new(:state => "drafted")
      # puts post.errors.full_messages.to_sentence unless post.valid?
      post.valid?.should eql(true)
      post.save.should eql(true)
    end

    it "should be valid and create a post with parts" do
      post = Atreides::Post.new(:state => "published")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors[:parts].nil?.should eql(false)
      post.errors[:title].nil?.should eql(false)

      post.title = "My test post"
      post.parts << Factory(:content_part_text)
      # puts post.errors.full_messages.to_sentence unless post.valid?
      post.valid?.should eql(true)
      post.save.should eql(true)
    end

    it "should not allow invalid state" do
      post = Atreides::Post.new(:state => "unknown")
      post.state.to_sym.should be :pending
    end

    it "should allow valid state" do
      post = Atreides::Post.new(:state => "drafted")
      post.state.to_sym.should be :drafted
    end

    it "should create a post from content-part attributes" do
      parts = [Factory(:content_part_text), Factory(:content_part_photos), Factory(:content_part_videos)]
      post = Atreides::Post.new(:title => "test post with parts", :state => "drafted", :part_ids => parts.map(&:id), :parts_attributes => parts.map(&:attributes))
      post.valid?.should eql(true)
      post.save.should eql(true)
    end

  end

  describe "next & previous" do


    before do
      Atreides::Post.delete_all
      @posts = []
      3.times do |i|
        @posts << Factory(:post, :published_at => i.hours.ago, :site => Atreides::Site.default)
      end
    end

    it "should be the previous post" do
      @posts[1].previous.id.should eql(@posts[2].id)
    end

    it "should be the next post" do
      @posts[1].next.id.should eql(@posts[0].id)
    end


  end

end

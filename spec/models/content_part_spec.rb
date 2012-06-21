require 'spec_helper'

describe Atreides::ContentPart do
  describe "validation" do

    before do
    end

    #
    # Validation Fails
    #
    it "should be invalid missing a body" do
      part = Atreides::ContentPart.new(:content_type => "text")
      part.valid?.should eql(false)
      part.save.should eql(false)
      part.errors[:body].nil?.should eql(false)
    end

    it "should be invalid missing a video" do
      part = Atreides::ContentPart.new(:content_type => "videos")
      part.valid?.should eql(false)
      part.save.should eql(false)
      part.errors[:video].nil?.should eql(false)
    end

    it "should be invalid missing photos" do
      part = Atreides::ContentPart.new(:content_type => "photos")
      part.valid?.should eql(false)
      part.save.should eql(false)
      part.errors[:photos].nil?.should eql(false)
      part.errors[:display_type].nil?.should eql(false)
    end

    it "should not be valid with unknown state and post_type" do
      post = Atreides::ContentPart.new(:content_type => "unknown")
      post.valid?.should eql(false)
      post.save.should eql(false)
      post.errors[:content_type].nil?.should eql(false)
    end

    #
    # Validation Passes
    #
    it "should be valid text content part" do
      part = Atreides::ContentPart.new(:content_type => "text", :body => "this is some test text")
      part.valid?.should eql(true)
      part.save.should eql(true)
    end

    it "should be valid photos content part" do
      part = Atreides::ContentPart.new(:content_type => "photos", :photos => [Factory(:photo)])
      part.valid?.should eql(true)
      part.save.should eql(true)
    end

    it "should be valid videos content part" do
      part = Atreides::ContentPart.new(:content_type => "videos", :videos => [Factory(:video)])
      part.valid?.should eql(true)
      part.save.should eql(true)
    end

  end

  describe "creation" do

    it "should create a content-part from photo attributes" do
      photos = [Factory(:photo), Factory(:photo), Factory(:photo)]
      part = Atreides::ContentPart.new(:content_type => "photos", :photo_ids => photos.map(&:id), :photos_attributes => photos.map(&:attributes))
      part.valid?.should eql(true)
      part.save.should eql(true)
    end

    it "should create a content-part from video attributes" do
      videos = [Factory(:video), Factory(:video), Factory(:video)]
      part = Atreides::ContentPart.new(:content_type => "videos", :video_ids => videos.map(&:id), :videos_attributes => videos.map(&:attributes))
      part.valid?.should eql(true)
      part.save.should eql(true)
    end

  end

end

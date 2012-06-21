require 'spec_helper'

describe Atreides::Photo do
  describe "validation" do
    before do
      @post = Factory(:published_post)
    end

    it "should update associated post on create" do
      photo = Factory.build(:photo, :photoable => @post)
      photo.stub(:fetch_remote_image).and_return(true)
      @post.should_receive(:touch)
      photo.save
    end

    it "should update associated post on update" do
      photo = Factory.build(:photo)
      photo.stub(:fetch_remote_image).and_return(true)
      photo.save
      photo.photoable = @post
      @post.should_receive(:touch)
      photo.save
    end
  end
end

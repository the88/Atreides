require 'spec_helper'

describe Atreides::Video do
  describe "validation" do
    before do
      @post = Factory(:published_post)
    end
    #
    # No longer possible since we're using nested RESTful forms - eg: you can't touch a non-existant object
    #
    # it "should update associated post on create" do
    #   video = Factory.build(:video, :part => @part)
    #   video.stub(:upload_video).and_return(true)
    #   @post.should_receive(:touch)
    #   video.save
    # end
    #
    # it "should update associated post on update" do
    #   video = Factory.build(:video)
    #   video.stub(:upload_video).and_return(true)
    #   video.save
    #   video.post = @post
    #   @post.should_receive(:touch)
    #   video.save
    # end
  end
end

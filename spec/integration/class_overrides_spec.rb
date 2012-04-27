require 'spec_helper'

describe "Dummy app overrides" do
  describe "in Dummy::Post" do
    it "inserts #hello in Atreides::Post" do
      Atreides::Post.hello.should eq("World ! (from Post.hello)")
    end

    it "inserts .greet in Atreides::Post" do
      post = Atreides::Post.new 
      post.greet.should eq("Hey you ! (from Post#greet)")
    end
  end

  describe "in Dummy::PostController" do
    it "inserted .greet in Atreides::PostController" do
      Atreides::PostsController.new.should respond_to 'greet'
    end
  end
end
require 'spec_helper'

describe Atreides::Comment do

  describe "Akismet spam feature" do
    before do
      @comment = Atreides::Comment.new(Factory.attributes_for(:comment))
    end

    it "should be dropped if considered as spam" do
      @comment.stub!(:spam?).and_return true
      @comment.save
      @comment.errors.keys.should include :base
    end

    it "should be accepted if not considered as spam" do
      @comment.stub!(:spam?).and_return false
      @comment.save
      @comment.errors.keys.should_not include :base
    end
  end

end
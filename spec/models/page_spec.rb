require 'spec_helper'

describe Atreides::Page do

  before do
    @page = Factory(:page)
  end

  it "should be valid and create a page" do
    page = Atreides::Page.new(:state => "pending")
    page.valid?.should eql(true)
    page.save.should eql(true)
  end

  it "should not be valid with missing fields" do
    page = Atreides::Page.new(:state => "published")
    page.valid?.should eql(false)
    [:title, :slug, :body].each do |col|
      page.errors[col].blank?.should eql(false)
    end
    page.save.should eql(false)
  end

end

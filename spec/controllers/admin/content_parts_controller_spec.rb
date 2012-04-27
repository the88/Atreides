require 'spec_helper'

describe Admin::Atreides::ContentPartsController do

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    sign_in Factory.create(:user_admin)
    @post = Factory(:published_post)
  end

  describe "GET new" do
    describe "with valid params" do
      it "returns a form in JS" do
        get :new, :post_id => @post.id
        response.should be_success
      end
    end

    describe "with invalid params" do
      it "returns an error message in JS" do
        get :new, :post_id => '-'
        response.should be_success
      end
    end
  end

  describe "POST reorder" do
    describe "with valid reorder params" do
      it "updates the parts display order" do
        parts = [Factory(:content_part_photos), Factory(:content_part_text), Factory(:content_part_videos)]
        parts_list = [parts[0].id, parts[2].id, parts[1].id]
        post :reorder, :post_id => @post.id, :parts_list => parts_list
        response.should be_success
        
        parts.each {|p| 
          p.reload
          p.display_order.should eql parts_list.index(p.id)+1
        }
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested part" do
      part = Factory(:content_part_photos)
      @post.parts << part
      @post.save
      
      delete :destroy, :post_id => @post.id, :id => part.id
      response.should be_success
      
      @post.reload
      @post.parts.include?(part).should eql false
    end
  end
end
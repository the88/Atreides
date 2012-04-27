class Admin::Atreides::FeaturesController < Atreides::AdminController

  helper 'admin/atreides/features'

  def index
    @show_as_dash = true
    @collection = {}
    Settings.tags.posts.features.map do |tag|
      @collection[tag] = end_of_association_chain.live.tagged_with(tag)
    end
  end

  def new
    # Create feature!
    @feature = end_of_association_chain.new(:state => "pending", :published_at => nil)
    @feature.save!
    super
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_feature_path(resource) }
    end
  end
  
  def create
    super do |wants|
      wants.html { redirect_to admin_features_path }
    end
  end

  def update
    super do |success, failure|
      success.html { redirect_to admin_features_path }
    end
  end

  def reorder
    key = params.keys.detect{|k| k.to_s.starts_with?('feature') }
    if params[key].is_a?(Array)
      i = 0
      params[key].each do |id|
        end_of_association_chain.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  private
  
  def end_of_association_chain
    current_site.features
  end
  
  def recource
    @feature ||= super
  end
  

  include Atreides::Extendable
end

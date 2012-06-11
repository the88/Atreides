class Atreides::HomeController < Atreides::PublicController

  helper 'atreides/posts'

  caches_page :robots
  before_filter :collection, :only => [:index, :sitemap, :feeds]

  def search
  end

  def feeds
    respond_to do |wants|
      wants.rss {
        render :template => "atreides/posts/index"
      }
      wants.atom {
        render :template => "atreides/posts/index"
      }
    end
  end

  def sitemap
    @posts = collection
    @countdowns = live_posts.tagged_with('countdown').limit(500)
    @pages = Atreides::Page.published.limit(500)
    respond_to do |wants|
      wants.xml
    end
  end

  def robots
    respond_to do |wants|
      wants.txt
    end
  end

  def error
    respond_to do |wants|
      wants.html {
        render "atreides/errors/500"
      }
    end
  end

  def not_found
    respond_to do |wants|
      wants.html {
        render "atreides/errors/404"
      }
    end
  end

  private

  def collection
    @collection ||= case action_name
      when 'sitemap'
        live_posts.limit(500).order("updated_at desc")
      when 'index', 'feeds'
        live_posts.paginate :page => params[:page]
      else
        []
      end
  end

  def live_posts
    Atreides::Post.live
  end

  include Atreides::Extendable
end

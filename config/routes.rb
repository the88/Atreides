Rails.application.routes.draw do
  root :to => "atreides/home#index"

  begin
    devise_for :users, :class_name => "Atreides::User", :path => "admin", :controllers => { :sessions => "admin/atreides/sessions" }, :path_names => { :sign_in => 'login', :sign_out => 'logout' }
  rescue ActiveRecord::StatementInvalid => e
    puts "Devise could not be set up for the user model."
    puts "Please make sure you have run 'rake atreides:install:migrations' and run any pending migrations."
    puts "Original exception: #{e.class}: #{e}"
  end

  match "/admin", :to => "atreides/admin_home#index", :as => "user_root" # Redirect to after login
  match "/admin", :to => "atreides/admin_home#index", :as => "admin"
  match "/admin/search", :to => "atreides/admin_home#search", :as => :admin_search
  match '/admin/analytics.(:format)', :to => "atreides/admin_home#analytics", :as => :admin_analytics
  match '/admin/analytics_data/:report', :to => "atreides/admin_home#analytics_data", :as => :admin_analytics_data
  match '/admin/github/issues', :to => 'admin/atreides/github#index', :as => :admin_github
  match '/admin/github/issues/:id', :to => 'admin/atreides/github#show', :as => :admin_github_issue
  match '/admin/switch_site/:site', :to => "atreides/admin_home#switch_site", :as => :admin_switch_site
  get   '/admin/setup/', :to => "atreides/admin_home#setup", :as => :atreides_setup
  post  '/admin/setup/', :to => "atreides/admin_home#setup!", :as => :atreides_do_setup

  namespace :admin do
    get "facebook" => "atreides/facebook#index", :as => :facebook
    post "facebook" => "atreides/facebook#update", :as => :update_facebook
    delete "facebook" => "atreides/facebook#destroy", :as => :destroy_facebook

    resources :posts, :controller => "atreides/posts" do
      collection do
        match ':state/:month/:year(.:format)', :to => "atreides/posts#index", :as => :filter, :constraints => { :state => "published", :year => /\d{4}/, :month => /\d{1,2}/ }
        match ':state(.:format)', :to => "atreides/posts#index", :as => :filter, :constraints => { :state => /drafted|published/ }
        get  :filter
        post :filter
      end
      resources :parts, :only => [:index, :new, :create, :destroy], :controller => "atreides/content_parts" do
        collection do
          post :reorder
        end
        resources :videos, :controller => "atreides/videos"
        resources :photos, :controller => "atreides/photos"
      end
    end
    resources :videos, :controller => "atreides/videos"
    resources :photos, :controller => "atreides/photos"
    resources :features, :controller => "atreides/features" do
      collection do
        get  :filter
        post :filter
        post :reorder
      end
      resource :photos, :controller => "atreides/photos"
    end
    resources :videos, :only => [:index, :destroy], :controller => "atreides/videos" do
      post :reorder, :on => :collection
    end
    resources :photos, :only => [:index, :destroy], :controller => "atreides/photos" do
      post :reorder, :on => :collection
    end
    resources :pages, :controller => "atreides/pages" do
      resources :messages, :only => [:index, :show, :delete], :controller => "atreides/messages"
      resources :photos, :controller => "atreides/photos"
    end
    # resources :orders
    # resources :products
    resources :users, :controller => "atreides/users" do
      collection do
        get :admins
      end
    end

    match  'dropbox/setup',    :to => "atreides/dropbox#setup"
    match  'dropbox/unlink',   :to => "atreides/dropbox#unlink"
    match  'dropbox/list',     :to => "atreides/dropbox#list"
    match  'dropbox/thumb',  :to => "atreides/dropbox#thumb", :as => "dropbox_thumbnail"

    %w(page product user).each do |p|
      match "new/#{p}", :to => "atreides/#{p.pluralize}#new"
    end
    match "new/feature", :to => "atreides/features#new", :as => :new_content
    resources :features, :collection => {:filter => :any, :reorder => :post}, :controller => "atreides/features" do
      resource :photo, :controller => "atreides/photos"
    end
    match "new/:type", :to => "atreides/posts#new", :as => :new_content
  end

  # Posts (be carefull, order matters!)
  match "/posts/tagged/:tag", :to => "atreides/posts#tagged", :as => "tagged_posts"
  match "/posts/archives", :to => "atreides/posts#archives", :as => "archive_posts"
  # match "/posts/preview", :to => "atreides/posts#preview", :as => "preview_post", :via => "post"
  resources :posts, :only => [:index], :controller => "atreides/posts" do
    member do
      get  :gallery_params
      get  :next
      get  :previous
    end
  end
  match "/posts/:id/:slug", :to => "atreides/posts#show", :as => "post", :via => "get"

  # RSS Feeds
  match "/feeds(.:format)", :to => "atreides/home#feeds", :as => "feeds"

  # Search
  match "/search", :to => "atreides/home#search", :as => "search"

  # Sitemap.xml
  match "/sitemap.xml", :to => "atreides/home#sitemap", :format => "xml"

  # Robots.txt
  match "/robots.txt", :to => "atreides/home#robots", :format => "txt"

  # Error Pages
  match "/500", :to => "atreides/home#error", :as => "error"
  match "/404", :to => "atreides/home#not_found", :as => "not_found"

  # Pages (MUST be last)
  # match "/pages/:id/preview", :to => "atreides/pages#preview", :as => "preview_page", :via => "post"
  match "/:page_slug", :to => "atreides/pages#show", :as => "page"

end

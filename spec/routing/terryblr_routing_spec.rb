require 'spec_helper'

describe 'Atreides' do
  it 'should show homepage' do
    { :get => '/' }.should route_to(:controller => 'atreides/home', :action => 'index')
  end

  it 'should display posts tagged by :tag' do
    { :get => '/posts/tagged/a_tag' }.should route_to(:controller => 'atreides/posts', :action => 'tagged', :tag => 'a_tag')
  end

  it 'should display post archives' do
    { :get => '/posts/archives' }.should route_to(:controller => 'atreides/posts', :action => 'archives')
  end

  it 'should display post' do
    { :get => '/posts/1/post_slug' }.should route_to(:controller => 'atreides/posts', :action => 'show', :id => '1', :slug => 'post_slug')
  end

  it 'should search for document' do
    { :get => '/search?search=SEARCH' }.should route_to(:controller => 'atreides/home', :action => 'search')
  end

  it 'should display robots.txt' do
    { :get => '/robots.txt' }.should route_to(:controller => 'atreides/home', :action => 'robots', :format => 'txt')
  end

  it 'should return error 404 page' do
    { :get => '/404' }.should route_to(:controller => 'atreides/home', :action => 'not_found')
  end

  it 'should return error 500 page' do
    { :get => '/500' }.should route_to(:controller => 'atreides/home', :action => 'error')
  end

  it 'should show page identified by its slug' do
    { :get => '/page_slug' }.should route_to(:controller => 'atreides/pages', :action => 'show', :page_slug => 'page_slug')
  end
end

describe 'Atreides::Admin' do

  it 'should switch admin site' do
    { :get => '/admin/switch_site/www' }.should route_to(:controller => 'atreides/admin_home', :action => 'switch_site', :site => 'www')
  end

  it 'should display posts' do
    { :get => '/admin/posts' }.should route_to(:controller => 'admin/atreides/posts', :action => 'index')
  end

  it 'should display new photos post' do
    { :get => '/admin/new/photos' }.should route_to(:controller => 'admin/atreides/posts', :action => 'new', :type => "photos")
  end

  it 'should display pages' do
    { :get => '/admin/pages' }.should route_to(:controller => 'admin/atreides/pages', :action => 'index')
  end

  it 'should display new page' do
    { :get => '/admin/pages/new' }.should route_to(:controller => 'admin/atreides/pages', :action => 'new')
  end

end

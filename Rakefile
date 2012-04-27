# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
end

RSpec::Core::RakeTask.new(:spec_html) do |spec|
  mkdir_p 'tmp/spec' unless File.exists? 'tmp/spec'
  spec.rspec_opts = '--format html --out tmp/spec/index.html'
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end


load 'lib/tasks/cucumber.rake'
load 'lib/tasks/yard.rake'

task :default => [:spec, :cucumber]

# Atreides::Application.load_tasks

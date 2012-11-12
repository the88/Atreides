require 'inherited_resources'
require 'haml'
require 'formtastic'
require 'settingslogic'
require 'will_paginate'
require 'validates_email_format_of'
require 'dropbox_sdk'
require 'analytical'
require 'jquery-rails'
require 'aws/s3'
require 'devise'
require 'oauth2'

require 'cancan'
# TODO: pull request in CanCan
module CanCan
  # For use with Inherited Resources
  class InheritedResource < ControllerResource # :nodoc:
    # defer this directly to Inherited Resources
    def load_collection
      @controller.send(:collection)
    end

    def resource_instance=(instance)
    end

    # def resource_instance
    #   @controller.send(:resource) if load_instance?
    # end

    def collection_instance=(instance)
    end

    def collection_instance
      @controller.send :collection
    end
  end
end

require File.expand_path('atreides/engine', File.dirname(__FILE__)) if defined?(Rails) && Rails::VERSION::MAJOR == 3

require "acts-as-taggable-on"
require "paperclip"
require "dynamic_form"
require "gattica"
require "delayed_job"
require 'mini_fb'

[ 'atreides/configuration',
  'atreides/schema',
  'atreides/extendable',
  'atreides/validators',
  'atreides/time_formats',
  'atreides/time_zone',
  "atreides/i18n_helpers",
  'atreides/base/base',
  'atreides/base/taggable',
  'atreides/base/aasmstates',
  'atreides/base/validation',
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

module Atreides
  class << self

    # Modify configuration
    # Example:
    #   Atreides.configure do |config|
    #     config.user_model = 'MyUser'
    #   end
    def configure
      yield configuration
    end

    # Accessor for Atreides::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

  end
end

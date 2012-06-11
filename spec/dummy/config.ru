# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

if defined? Thin
  require 'rack/fiber_pool'
  require "em-http"
  require "em-synchrony"
  Dummy::Application.config.middleware.delete Rack::Lock
  Dummy::Application.config.middleware.use Rack::CommonLogger
  Dummy::Application.config.middleware.use Rack::ShowExceptions
  Dummy::Application.config.middleware.use Rack::FiberPool
  Dummy::Application.config.threadsafe!
end

run Dummy::Application

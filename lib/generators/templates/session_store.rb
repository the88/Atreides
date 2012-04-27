# Be sure to restart your server when you modify this file.
if Rails.env.production?
  require 'action_dispatch/middleware/session/dalli_store'
  username = "username"
  password = "pass"
  server = "server"
  Rails.application.config.session_store :dalli_store,
        :memcache_server => ["#{username}:#{password}@#{server}"],
        :namespace => "#{Settings.app_name.parameterize.gsub(/-/,"_")}_sessions",
        :key => Settings.session_key,
        :expire_after => 90.minutes
elsif Rails.env.staging?
  require 'action_dispatch/middleware/session/dalli_store'
  username = "username"
  password = "pass"
  server = "server"
  Rails.application.config.session_store :dalli_store,
        :memcache_server => ["#{username}:#{password}@#{server}"],
        :namespace => "#{Settings.app_name.parameterize.gsub(/-/,"_")}_sessions",
        :key => Settings.session_key,
        :expire_after => 90.minutes
else
  Rails.application.config.session_store :active_record_store,
    :key => Settings.session_key,
    :cookie_only => false,
    :secret => 'ADD_A_SECRET_HERE_PLEASE'
end
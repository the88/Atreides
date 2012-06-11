require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record/migration'

module Atreides
  module Generators
    class AtreidesGenerator < Rails::Generators::Base
      namespace "atreides"
      include Rails::Generators::Migration

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), '..', 'templates')
      end

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname)
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end

      def create_migration_file
        generate('acts_as_taggable_on:migration')
        generate('delayed_job')
        # generate('devise:install') # Run 'rails g devise:install' instead!

        %w(create_videos create_photos create_orders create_posts
           create_pages create_likes create_comments create_messages
           create_features create_products create_line_items create_links
           create_votes create_tweets create_sessions create_sites
           create_content_parts add_userid_to_resources).each do |f|
          src = "#{f}.rb"
          dst = "db/migrate/#{src}"
          migration_template(src, dst) rescue puts $!
        end
      end

      def create_configuration_file
        # Use Dalli store
        append_to_file "Gemfile" do
%Q{
gem 'dalli'
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"
}
        end
        gsub_file 'config/environments/production.rb', "# config.cache_store = :mem_cache_store", "config.cache_store = :dalli_store"

        copy_file 'initializer.rb', 'config/initializers/atreides.rb'
        copy_file 'string_extensions.rb', 'config/initializers/string_extensions.rb'
        copy_file 'sass.rb', 'config/initializers/sass.rb'
        copy_file 'new_relic.rb', 'config/initializers/new_relic.rb'
        copy_file 'unicorn.rb', 'config/unicorn.rb'
        copy_file 'settings.yml', 'config/settings.yml'
        copy_file 'oembed.yml', 'config/oembed.yml'
        copy_file 'devise.rb', 'config/initializers/devise.rb'
        copy_file 'locales/devise_en.yml', 'config/locales/devise_en.yml'
        copy_file 'delayed_job.rb', 'config/initializers/delayed_job.rb'
        copy_file 'disqussion.rb', 'config/initializers/disqussion.rb'
        copy_file 'em-net-http_override.rb', 'config/initializers/em-net-http_override.rb'
        copy_file 'Procfile', 'Procfile'

        # Session store with Dalli/Memcache setup built-in
        copy_file 'session_store.rb', 'config/initializers/session_store.rb'
      end
    end
  end
end

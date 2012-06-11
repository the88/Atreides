require "rails"

module Atreides
  class Engine < Rails::Engine
    paths['db/migrate']         = 'db/migrate'
    # paths['atreides/base']    = 'atreides/base'
    paths['app/inputs'] = 'app/inputs'

    # Since the database can't be set up when running the generators,
    # we move the models path to autoload instead of eager_load.
    # otherwise, we would get "could not find table 'xxxx'" exceptions.
    config.eager_load_paths -= [ paths["app/models"].first ]
    config.autoload_paths << paths["app/models"].first
    config.autoload_paths += %W(#{Rails.root}/app/atreides/models)
    config.eager_load_paths += [ paths["app/inputs"].first ]

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    initializer :load_overrides do
      filename = File.expand_path('config/initializers/overrides', Rails.root)
      require filename if File.exists?(filename)
    end

    initializer "atreides.asset_pipeline" do |app|
      app.config.assets.precompile += %w( atreides/admin_edit.js atreides/admin.js atreides/public.js atreides/admin.css atreides/public.css )
    end

    initializer 'atreides.formtastic.inputs' do
      load_path = paths['app/inputs'].first
      matcher = /\A#{Regexp.escape(load_path)}\/(.*)\.rb\Z/
      Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
        require_dependency file.sub(matcher, '\1')
      end
    end

    rake_tasks do
      load 'atreides/railties/tasks.rake'
    end
  end
end

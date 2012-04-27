require "rails"

module Atreides
  class Engine < Rails::Engine
    paths['app/coffeescripts']  = 'app/coffeescripts'
    paths['db/migrate']         = 'db/migrate'
    # paths['atreides/base']    = 'atreides/base'

    # Since the database can't be set up when running the generators,
    # we move the models path to autoload instead of eager_load.
    # otherwise, we would get "could not find table 'xxxx'" exceptions.
    config.eager_load_paths -= [ paths["app/models"].first ]
    config.autoload_paths << paths["app/models"].first
    config.autoload_paths += %W(#{Rails.root}/app/atreides #{Rails.root}/app/atreides/models)

    config.gem 'devise'
    config.gem 'cancan'
    config.gem 'barista'

    # Force routes to be loaded if we are doing any eager load.
    config.before_eager_load { |app| app.reload_routes! }

    initializer :load_overrides do
      filename = File.expand_path('config/initializers/overrides', Rails.root)
      require filename if File.exists?(filename)
    end

    rake_tasks do
      load 'atreides/railties/tasks.rake'
    end
  end
end

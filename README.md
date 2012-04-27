# Atreides

## Installation guide ##

1) Our generator loads the application environment, and so will NOT work unless the `devise.rb`
initializer has already been created.

    `rails g devise:install`

2) Then, generate the Atreides:

    rails g atreides
    rake atreides:install:migrations

3) Configure the app to use the ActiveRecord session store, like this:
(Otherwise, the QQ photo uploader will not work)

    $ cat config/initializers/session_store.rb
    Rails.application.config.session_store :active_record_store,
      :key => Settings.session_key,
      :cookie_only => false,
      :secret => 'b2b9dc917f44439635be5b7d07af4b501f14a8f267b2461549fce7229e26fe29f62c3fd42e521d5c570dc524e32d2068a24e1f3490760fb34c09874e41d49fcc'

4) Migrate the DB

    rake db:migrate

5) Chillax


## Running the tests: ##

    bundle exec rake spec
    bundle exec cucumber

To use spork, first launch a Sport server like this:

    RAILS_ENV=test spork rspec &2> /dev/null
    RAILS_ENV=test spork cucumber &2> /dev/null

Then, add the command-line option `--drb` to your RSpec or Cucumber command
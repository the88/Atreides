# Atreides

## Installation guide ##

```sh
rails new cool_website
cd cool_website
echo "gem 'atreides'" >> Gemfile
bundle install # or bundle update
rails g atreides
rake db:migrate
rails s
```

Then visit <http://localhost/admin> to get started.

Many of the plugins require configuration settings. See config/settings.yml.

## Running the tests: ##

    bundle exec rake spec
    bundle exec cucumber

To use spork, first launch a Sport server like this:

    RAILS_ENV=test spork rspec &2> /dev/null
    RAILS_ENV=test spork cucumber &2> /dev/null

Then, add the command-line option `--drb` to your RSpec or Cucumber command

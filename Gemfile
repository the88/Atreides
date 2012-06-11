# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"

gem "analytical", :git => "git://github.com/mathieuravaux/analytical.git"
gem "gattica", :git => "http://github.com/chrisle/gattica.git"

gem "thin", :require => nil
gem "eventmachine", ">= 1.0.0.beta.3", :require => nil
gem "em-http-request", :require => nil
gem "em-net-http", :require => nil
gem "em-synchrony", :require => nil

group :development, :test do
  gem 'capybara'
  gem 'awesome_print'
  gem 'growl'
  gem 'ruby-growl'
  gem 'hpricot'
  gem 'guard'
end

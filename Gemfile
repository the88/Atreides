# reference: http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source "http://rubygems.org"
gemspec

gem "aws-s3",  :require => "aws/s3"
gem "dropbox"
gem "eventmachine", ">= 1.0.0.beta.3"
gem "thin"

gem "analytical", :git => "git://github.com/mathieuravaux/analytical.git"
gem "gattica", :git => "http://github.com/mathieuravaux/gattica.git"
gem "em-http-request", :git => "git://github.com/igrigorik/em-http-request.git",  :tag => "b8138b7edc671e24235e"
gem "em-net-http"
gem "em-synchrony", :git => "git://github.com/igrigorik/em-synchrony.git"

group :development, :test do
  gem 'capybara'
  gem 'awesome_print'
  gem 'thin'
  gem 'growl'
  gem 'ruby-growl'
  gem 'hpricot'
  gem 'guard'
end

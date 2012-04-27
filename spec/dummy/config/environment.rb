# Load the rails application
puts "\nLoading the Rails app (application.rb)..."
require File.expand_path('../application', __FILE__)
puts "Loaded application.rb."

puts "\nInitializing the Rails app..."
Dummy::Application.initialize!
puts "Done initializing the Rails app."

unless ARGV.any? {|a| a =~ /^gems/} # Don't load anything when running the gems:* tasks

  begin
    require 'yard'

    YARD::Rake::YardocTask.new do |t|
      t.files = ['lib/atreides/**/*.rb', 'lib/atreides.rb', 'app/**/*.rb']
      t.options = ['-c.yardcache', '--protected', '--private']
    end

  rescue LoadError
    desc 'yard rake task not available (yard not installed)'
    task :yard do
      abort 'Yard rake task is not available. Be sure to install yard as a gem'
    end
  end

end

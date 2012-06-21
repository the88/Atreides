module ActiveRecord
  class Migration
    class << self
      def copy(destination, sources, options = {})
        copied = []

        FileUtils.mkdir_p(destination) unless File.exists?(destination)

        destination_migrations = ActiveRecord::Migrator.migrations(destination)
        last = destination_migrations.last
        sources.each do |name, path|
          source_migrations = ActiveRecord::Migrator.migrations(path)

          source_migrations.each do |migration|
            source = File.read(migration.filename)
            source = "# This migration comes from #{name} (originally #{migration.version})\n#{source}"

            if duplicate = destination_migrations.detect { |m| m.name == migration.name }
              options[:on_skip].call(name, migration) if File.read(duplicate.filename) != source && options[:on_skip]
              next
            end

            # migration.version = next_migration_number(last ? last.version + 1 : 0).to_i
            new_path = File.join(destination, "#{migration.version}_#{migration.name.underscore}.rb")
            old_path, migration.filename = migration.filename, new_path
            last = migration

            FileUtils.cp(old_path, migration.filename)
            copied << migration
            options[:on_copy].call(name, migration, old_path) if options[:on_copy]
            destination_migrations << migration
          end
        end

        copied
      end
    end
  end
end

# class Hash
#   def to_query
#     result = []
#     each do |k, v|
#       result << "#{k}=#{v}"
#     end
#     result.join("&")
#   end
# end

namespace :atreides do
  namespace :install do
    desc "Copy migrations from Atreides to application"
    task :migrations => :"db:load_config" do

      # Adapted from rails edge activerecord/lib/active_record/railties/databases.rake
      on_skip = Proc.new do |name, migration|
        puts "NOTE: Migration #{migration.name} from #{name} has been skipped. Migration with the same name already exists."
      end

      on_copy = Proc.new do |name, migration, old_path|
        puts "Copied migration #{migration.name} from #{name}"
      end

      ActiveRecord::Migration.copy( 'db/migrate', { 'atreides' => Atreides::Engine.new.paths['db/migrate'].first }, :on_skip => on_skip, :on_copy => on_copy)
    end
  end
end

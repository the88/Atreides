module Atreides
  module Schema
    COLUMNS = {:published_at  => :datetime,
               :state         => :string,
               :time_zone      => :string }


     def self.included(base)
       ActiveRecord::ConnectionAdapters::Table.send :include, TableDefinition
       ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TableDefinition
       ActiveRecord::ConnectionAdapters::AbstractAdapter.send :include, Statements

       if defined?(ActiveRecord::Migration::CommandRecorder) # Rails 3.1+
         ActiveRecord::Migration::CommandRecorder.send :include, CommandRecorder
       end
     end


    module Statements
      def add_publishable(table_name)
        COLUMNS.each_pair do |column_name, column_type|
          add_column(table_name, column_name, column_type)
        end
      end

      def remove_publishable(table_name)
        COLUMNS.each_pair do |column_name, column_type|
          remove_column(table_name, column_name)
        end
      end
    end

    module TableDefinition
      def publishable()
        COLUMNS.each_pair do |column_name, column_type|
          column(column_name, column_type)
        end
      end
    end

    module CommandRecorder
      def add_publishable(*args)
        record(:add_publishable, args)
      end

      private

      def invert_add_publishable(args)
        [:remove_publishable, args]
      end
    end
  end
end
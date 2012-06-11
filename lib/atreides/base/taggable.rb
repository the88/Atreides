module Atreides
  class Base < ActiveRecord::Base

    #
    # Module providing common tagging functionality. Uses the _acts_as_taggable_ mixin.
    #
    module Taggable
      def self.included(recipient)
        recipient.class_eval do

          # Throws errors if table doesn't exist on first project setup
          if recipient.table_exists?
            acts_as_taggable

            if Rails.env.development? || Rails.env.staging?
              Settings.load! # Needed for dev env when reloading class caches
            end

            if defined?(Settings.tags[self.table_name]) && defined?(Settings.tags[self.table_name]['groups'])
              acts_as_taggable_on Settings.tags[self.table_name]['groups']
              scope :tagged, lambda { |tags|
                tags_sql = tags.is_a?(Array) ? tags.map{|t|"'#{t}'"}.join(",") : "'#{tags}'"
                select("#{table_name}.*").
                joins("JOIN taggings ON taggings.taggable_id = #{table_name}.id AND taggings.taggable_type IN ('#{to_s}')").
                where("taggings.tag_id in (SELECT id from tags where LOWER(name) IN (#{tags_sql.downcase}))")
              }
            end
          end

          # Add callback to normalize tags
          before_save :normalize_tags

          private

          def normalize_tags
            self.tag_list = self.tag_list.map(&:parameterize)
          end

        end
      end
    end
  end
end

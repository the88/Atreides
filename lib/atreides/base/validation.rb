module Atreides
  class Base < ActiveRecord::Base

    #
    # Module providing common validations functionality.
    #
    module Validation
      def self.included(recipient)
        recipient.class_eval do
          before_validation :update_slug

          # Sets the object's slug. Slugs are used to create SEO friendly URLs.
          def update_slug
            # Set slug if not set
            if respond_to?(:slug) and respond_to?(:title)
              self.slug = title? ? title.parameterize : id if !slug? or slug.match(/^\d+$/)
            end
          end
        end
      end
    end
  end
end

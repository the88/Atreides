module Atreides
    module Extendable
      extend ActiveSupport::Concern

      included do |base|
        base.class_exec {
          public
          Atreides.configuration.inject_overrides base
        }
      end
    end
end

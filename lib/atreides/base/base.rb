module Atreides
  
  # Base class inherited by every model in Atreides
  class Base < ActiveRecord::Base

    #
    # Includes
    #
    include ActiveModel::Validations

    #
    # Class definitions
    #
    self.abstract_class = true

    # Give a string identifying the model based on it's properties.
    # In order:
    # - _slug_ if it has a property *slug*
    # - _id-name_ if it has a property *name*
    # - _id-title_ if it has a property *title*
    # - _id_ otherwise
    # @return A string describing an instance of a model
    def to_param
      return slug.to_s if self.respond_to?(:slug) and !slug.blank?
      return "#{id}-#{name.to_s.parameterize}" if self.respond_to?(:name) and self.name?
      return "#{id}-#{title.to_s.parameterize}" if self.respond_to?(:title) and self.title?
      id.to_s
    end

    # Give a DOM friendly ID for an object. This is used extensively with UI Javascript behaviours.
    # @param [Prefix] prefix the id with a custom name. Defaults to the objects model name.
    # @return [String] the dom id
    def dom_id(prefix=nil)
      display_id = new_record? ? "new" : id
      prefix ||= self.class.name.demodulize
      prefix != :bare ? "#{prefix.to_s.parameterize('_')}_#{display_id}" : display_id
    end

  end
end

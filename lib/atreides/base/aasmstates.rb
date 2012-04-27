module Atreides
  class Base < ActiveRecord::Base
    
    #
    # Common class responsible for the management of Atreides model states. The focus is on managing the states between creation and publication of content.
    #
    module AasmStates
      def self.included(recipient)
        recipient.class_eval do
          require 'aasm'
          include ::AASM
          aasm_column :state
          aasm_initial_state :pending
          aasm_state :pending
          aasm_state :drafted
          aasm_state :queued
          aasm_state :published, :enter => :do_publish

          aasm_event :publish do
            transitions :from => [:pending, :drafted, :queued], :to => :published
          end

          aasm_event :draft do
            transitions :from => [:pending, :published, :queued], :to => :drafted
          end

          aasm_event :queue do
            transitions :from => [:pending, :published, :drafted], :to => :queued
          end
          
          #
          # Validation
          #
          validates :state, :inclusion => { :in => aasm_states.map(&:name).compact.map(&:to_s) }

          #
          # Scopes
          #
          aasm_states.map(&:name).each do |state|
            scope state, where(:state => state.to_s)
          end

          scope :by_state, lambda { |state|
            where(:state => state.to_s)
          }

          scope :live, lambda {
            # Needs to be sep variable or AR will cache the first time and it'll never change
            where("#{table_name}.state = 'published' and #{table_name}.published_at <= ?", Time.zone.now)
          }

          #
          # Callbacks
          #
          after_initialize :set_initial_state
          
          # Make sure that the state of all objects are set after initialization
          def set_initial_state
            # Touch the state attribute and if missing reload
            self.state rescue self.reload
            
            self.state ||= self.class.aasm_initial_state
          end

          before_validation :stringify_state
          def stringify_state
            self.state = state.to_s if state?
          end

          #
          # Methods
          #
          
          # Create a list if states used in a HTML select drop-down
          def states_for_select
            [
              [I18n.t(:publish_now,  :scope => [:model, :states]).capitalize, :publish_now],
              [I18n.t(:drafted,      :scope => [:model, :states]).capitalize, :drafted],
              # ["Add to queue", :queued],
              [I18n.t(:published_at, :scope => [:model, :states]).capitalize, :published_at]
            ]
          end

          # Set state.
          # If the value is 'published' then update the published_at attribute to now
          def state=(value)
            case value.to_s.to_sym
            when :publish_now
              self[:state] = "published"
              self.published_at = Time.zone.now
            when :published_at
              self[:state] = "published"
            else
              self[:state] = value if self.class.aasm_states.map(&:name).include?(value.to_s.to_sym)
            end
          end

          # Has this object been published? Is it live?
          def live?
            self.published? and self.published_at? and self.published_at < Time.zone.now
          end

          # Is this object schedule to be published on a date?
          def publish_on_date?
            self.published? and self.published_at?
          end

          private

          # Override this in local models
          def do_publish
          end
        end
      end
    end
  end
end
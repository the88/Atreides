require 'unicode_utils'

module Atreides

  # Implement a series of helpers to translate Atreides.
  # These are injected into ActionView::Helpers::TranslationHelper
  module I18nHelpers

    def self.included(recipient)
      recipient.class_eval do

        def atreides_translate *args
          options = args.extract_options!
          scope_ = options.fetch(:scope, [])
          # puts "ttt: #{args[0]}, scope_: #{scope_.inspect}"
          if args[0].to_s.starts_with?('.') && scope_.include?('atreides')
            # puts "already correctly scoped"
            args << options
            translate(*args)
          else
            # puts "re-scoping"
            raise "NotImplemented" unless scope_.empty?
            options[:scope] = 'atreides'
            args << options
            translate(*args)
          end
        end

        def capitalize(str)
          str.sub str.first, UnicodeUtils.upcase(str.first, I18n.locale)
        end

        def atreides_translate_capitalize(*args)
          capitalize atreides_translate(*args)
        end

        def atreides_translate_titleize(*args)
          if I18n.locale == :en
            UnicodeUtils.titlecase atreides_translate(*args), I18n.locale
          else
            capitalize atreides_translate(*args)
          end
        end

        alias :tt :atreides_translate
        alias :ttc :atreides_translate_capitalize
        alias :ttt :atreides_translate_titleize

        if recipient.respond_to? :helper_method
          helper_method :atreides_translate, :atreides_translate_capitalize, :atreides_translate_titleize
          helper_method :tt, :ttc, :ttt
        end
      end
    end
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      unloadable
      include Atreides::I18nHelpers
    end
  end
end

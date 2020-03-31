# frozen_string_literal: true

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file
        set_allowed_fields

        execute_action(@allowed_fields[:action])
      end

      def execute_action(action)
        case action
        when nil
          Notify.info 'Action not provided, creating new note...'
          Action::Create.new(@allowed_fields)
        when 'create'
          Action::Create.new(@allowed_fields)
        when 'duplicate_previous'
          Action::DuplicatePrevious.new(@allowed_fields)
        else
          Action::Default.new(action: action)
        end
      end

      private

      def set_allowed_fields
        @allowed_fields = config.translate_placeholders.pluck(
          :title,
          :title_format,
          :notebook,
          :path,
          :action,
          :tags
        )
      end

      def grammar
        terms = Grammar.new
        terms.notebook = @allowed_fields[:notebook]
        terms.tags = {
          day: Date.today.yday,
          week: Date.today.cweek
        }
        terms.created = Date.new(Date.today.year, 1, 1).strftime('%Y%m%d')
        terms
      end
    end
  end
end

# frozen_string_literal: true

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file
        configure_allowed_fields
        action = @allowed_fields[:action]

        # if action != 'create_multiple'
        #   return Notify.warning("Note already exists\n- #{@link}") if note_exists?

        #   Notify.info 'Note not found, creating a new one'
        # end

        # execute_action(action)
        runner = ActionRunner.new
        runner.params = template_contents
        runner.execute
      end

      def execute_action(action)
        case action
        when nil
          Notify.info 'Action not provided, creating new note...'
          Action::Create.new(@allowed_fields)
        when 'create'
          Action::Create.new(@allowed_fields)
        when 'create_multiple'
          Action::CreateMultiple.new(@allowed_fields, self)
        when 'duplicate_previous'
          Action::DuplicatePrevious.new(@allowed_fields)
        else
          Action::Default.new(action: action)
        end
      end

      private

      def note_exists?
        helper = Evertils::Helper::Note.instance
        note = helper.wait_for_with_grammar(grammar)

        @link = helper.external_url_for(note.entity) unless note.entity.nil?

        note.exists?
      end

      def configure_allowed_fields
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

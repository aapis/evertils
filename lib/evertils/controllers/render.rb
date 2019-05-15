# frozen_string_literal: true

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file
        set_allowed_fields

        return Notify.warning("Note already exists\n- #{@link}") if note_exists?

        Notify.info 'Note not found, creating a new one'

        execute_action(@allowed_fields[:action])
      end

      def note_exists?
        helper = Evertils::Helper.load('Note')
        note = helper.wait_for_by_title(@allowed_fields[:title], @allowed_fields[:notebook], 3)
        @link = helper.external_url_for(note.entity) unless note.entity.nil?

        note.exists?
      end

      def execute_action(action)
        case action
        when nil
          Notify.info 'Action not provided, creation new note...'
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
    end
  end
end

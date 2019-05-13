# frozen_string_literal: true

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file(config)
        @config = config.translate_placeholders.pluck(:title, :notebook, :path, :action)

        return Notify.warning("Note already exists\n- #{@link}") if note_exists?

        Notify.info 'Note not found, creating a new one'

        execute_action(@config[:action].to_sym || :create)
      end

      def note_exists?
        helper = Evertils::Helper.load('Note')
        note = helper.wait_for_by_title(@config[:title], @config[:notebook], 3)
        @link = helper.external_url_for(note.entity) unless note.entity.nil?

        note.exists?
      end

      def execute_action(action)
        case action
        when :duplicate_previous
          Action::DuplicatePrevious.new(@config)
        else
          Action::Create.new(@config)
        end
      end
    end
  end
end

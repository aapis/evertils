# frozen_string_literal: true

require 'evertils/common/query/simple'

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file(config)
        @config = config.translate_placeholders.pluck(:title, :notebook)

        return Notify.warning("Note already exists\n- #{@link}") if note_exists?

        Notify.info 'Note not found, creating a new one'

        query = Evertils::Common::Query::Simple.new
        query.create_note_from_yml(@config[:path])
      end

      def note_exists?
        helper = Evertils::Helper.load('Note')
        note = helper.wait_for_by_title(@config[:title], @config[:notebook], 3)
        @link = helper.external_url_for(note.entity) unless note.entity.nil?

        note.exists?
      end
    end
  end
end

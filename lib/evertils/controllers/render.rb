require 'evertils/common/query/simple'

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file(config)
        return Notify.warning("Note already exists\n- #{@link}") if note_exists?

        query = Evertils::Common::Query::Simple.new
        query.create_note_from_yml(config[:path])
      end

      def note_exists?
        helper = Evertils::Helper.load('Note')
        note = helper.wait_for(:Daily, 5)
        @link = helper.external_url_for(note.entity) unless note.entity.nil?

        note.exists?
      end
    end
  end
end
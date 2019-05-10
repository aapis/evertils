require 'evertils/common/query/simple'

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file(config)
        helper = Evertils::Helper.load('Note')
        note = helper.wait_for(:Daily)
        link = helper.external_url_for(note.entity)

        return Notify.warning("Note already exists\n- #{link}") if note.exists?

        query = Evertils::Common::Query::Simple.new
        query.create_note_from_yml(config[:path])
      end
    end
  end
end
require 'evertils/common/query/simple'

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file(config)
        query = Evertils::Common::Query::Simple.new
        query.create_note_from_yml(config[:path])
      end
    end
  end
end
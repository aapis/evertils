# frozen_string_literal: true

require 'evertils/common/query/simple'

module Evertils
  module Action
    class Create < Action::Base
      def initialize(args)
        puts args.inspect
        exit
        query = Evertils::Common::Query::Simple.new
        query.create_note_from_yml(args[:path])
      end
    end
  end
end

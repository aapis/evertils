# frozen_string_literal: true

require 'evertils/common/query/simple'

module Evertils
  module Action
    class Create < Action::Base
      def initialize(args)
        @args = args
        query = Evertils::Common::Query::Simple.new

        query.create_note_from_hash(allowed_args)
      end

      private

      def allowed_args
        @args.to_h.reject { |key, _| key == :action }
      end
    end
  end
end

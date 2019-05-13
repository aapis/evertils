# frozen_string_literal: true

module Evertils
  module Action
    class Base
      def initialize(args)
        @args = args
        @note_helper = Evertils::Helper.load('Note')
        @api = Evertils::Helper.load('ApiEnmlHandler', {})
      end
    end
  end
end
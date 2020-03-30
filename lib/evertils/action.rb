# frozen_string_literal: true

module Evertils
  module Action
    class Base
      def initialize(args)
        @args = args
        @note_helper = Evertils::Helper::Note.instance
        @api = Evertils::Helper::ApiEnmlHandler.new
      end
    end
  end
end
# frozen_string_literal: true

module Evertils
  module Action
    class Default < Action::Base
      def initialize(args)
        Notify.error "Unknown action '#{args[:action]}'"
      end
    end
  end
end

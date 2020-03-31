# frozen_string_literal: true

module Evertils
  module Action
    class CreateMultiple < Action::Base
      def initialize(notes)
        return unless notes.is_a? Array

        notes.each do |child|
          Notify.info("Creating #{child['label']}")

          # avoid infinite recursion
          next if ['create_multiple'].include?(child['action'])

          child['path'].gsub!('%EVERTILS_CONF_TYPE_PATH%', '~/.evertils/templates/type')

          runner = ActionRunner.new
          runner.params = Evertils::Type.new(child['path']).params
          runner.execute
        end
      end
    end
  end
end

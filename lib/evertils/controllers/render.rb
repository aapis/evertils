# frozen_string_literal: true

module Evertils
  module Controller
    class Render < Controller::Base
      def from_file
        configure_allowed_fields

        runner = ActionRunner.new
        runner.params = Evertils::Type.new(@allowed_fields[:path]).params
        runner.execute
      end

      def configure_allowed_fields
        @allowed_fields = config.translate_placeholders.pluck(
          :title,
          :title_format,
          :notebook,
          :path,
          :action,
          :tags
        )
      end
    end
  end
end

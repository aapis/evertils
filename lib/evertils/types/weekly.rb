module Evertils
  module Type
    class Weekly < Type::Base
      NOTEBOOK = :Weekly

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @title = @format.date_templates[NOTEBOOK]
        @content = @format.template_contents(NOTEBOOK)
      end

      #
      # @since 0.3.9
      def tags
        ["week-#{Date.today.cweek}"]
      end

      #
      # @since 0.3.7
      def should_create?
        is_monday = Date.today.monday?

        weekly_note_title = @format.date_templates[NOTEBOOK]
        found = @model.find_note_contents(weekly_note_title)

        found.entity.nil? && is_monday
      end
    end
  end
end

module Evertils
  module Type
    class Weekly < Type::Base
      NOTEBOOK = :Weekly
      COLOUR = 0xffe8b7

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
    end
  end
end

module Evertils
  module Type
    class Daily < Type::Base
      NOTEBOOK = :Daily

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
        ["day-#{Date.today.yday}"]
      end
    end
  end
end

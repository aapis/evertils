module Evertils
  module Type
    class Daily < Type::Base
      attr_reader :title, :content, :notebook

      NOTEBOOK = :Daily

      #
      # @since 0.3.7
      def initialize
        super

        @title = @format.date_templates[NOTEBOOK]
        @content = @format.template_contents(NOTEBOOK)
        @content += to_enml($config.custom_sections[NOTEBOOK]) unless $config.custom_sections.nil?
      end
    end
  end
end

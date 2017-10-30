module Evertils
  module Type
    class Monthly < Type::Base
      NOTEBOOK = :Monthly
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
        ["month-#{Date.today.month}"]
      end

      #
      # @since 0.3.7
      def should_create?
        today_is_first_of_month = Date.today.day == 1

        monthly_note_title = @format.date_templates[NOTEBOOK]
        found = @model.find_note_contents(monthly_note_title)
        result = found.entity.nil? && today_is_first_of_month

        Notify.warning "#{self.class.name} skipped, note already exists" unless result

        result
      end
    end
  end
end

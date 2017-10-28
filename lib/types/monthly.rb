module Evertils
  module Type
    class Monthly < Type::Base
      attr_reader :title, :content, :notebook

      NOTEBOOK = :Monthly

      #
      # @since 0.3.7
      def initialize
        super

        @title = @format.date_templates[NOTEBOOK]
        @content = @format.template_contents(NOTEBOOK)
        @content += to_enml($config.custom_sections[NOTEBOOK]) unless $config.custom_sections.nil?

        # BUG: inability to tag notes lies somewhere in evertils-common,
        # specifically in how note.tag works
        # As this is non-functional, lets not run it - commented out for now
        # tag_manager = Evertils::Common::Manager::Tag.instance
        # month_tag = tag_manager.find_or_create("month-#{Date.today.month}")
        # note.tag(month_tag.prop(:name))
      end

      #
      # @since 0.3.7
      def notebook
        NOTEBOOK
      end

      #
      # @since 0.3.7
      def should_create?
        today_is_first_of_month = Date.today.day == 1

        monthly_note_title = @format.date_templates[NOTEBOOK]
        found = @model.find_note_contents(monthly_note_title)

        !found.entity.nil? && today_is_first_of_month
      end
    end
  end
end
module Evertils
  module Type
    class Weekly < Type::Base
      attr_reader :title, :content, :notebook

      NOTEBOOK = :Weekly

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
        # week_tag = tag_manager.find_or_create("week-#{Date.today.cweek}")
        # note.tag(week_tag.prop(:name))
      end

      #
      # @since 0.3.7
      def should_create?
        today = Date.today
        is_monday = today.monday?

        weekly_note_title = @format.date_templates[NOTEBOOK]
        found = @model.find_note_contents(weekly_note_title)

        !found.entity.nil? && is_monday
      end
    end
  end
end

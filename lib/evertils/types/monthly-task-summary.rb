module Evertils
  module Type
    class MonthlyTaskSummary < Type::Base
      attr_reader :title, :content, :notebook

      NOTEBOOK = :'Monthly Task Summaries'

      #
      # @since 0.3.7
      def initialize(*args)
        super(*args)

        @name = @args.first
        @title = "#{@name} #{DateTime.now.strftime('%m-%Y')}"
        @content = @format.template_contents(NOTEBOOK)
        @content += to_enml($config.custom_sections[NOTEBOOK]) unless $config.custom_sections.nil?

        # BUG: inability to tag notes lies somewhere in evertils-common,
        # specifically in how note.tag works
        # As this is non-functional, lets not run it - commented out for now
        # tag_manager = Evertils::Common::Manager::Tag.instance
        # month_tag = tag_manager.find_or_create("month-#{Date.today.month}")
        # mts_note.tag(month_tag.prop(:name))

        # TODO: commented out until support for multiple tags is added
        # client_tag = tag_manager.find_or_create(@name)
        # mts_note.tag(client_tag.prop(:name))
      end

      #
      # @since 0.3.7
      def notebook
        NOTEBOOK
      end
    end
  end
end
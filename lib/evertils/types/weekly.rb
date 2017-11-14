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

      #
      # @since 0.3.15
      def add_daily_note_link
        xml = @api.from_str(@entity.content)
        xml_helper = Evertils::Helper.load('Xml', xml)

        a = xml_helper.a(
          internal_url_for(@entity),
          @format.date_templates[:Daily]
          )
        li = xml_helper.li(a)

        xml.search('en-note>div:first-child>ul li:last-child').after(li)

        @entity.content = xml

        Notify.success("#{self.class.name} updated, added daily note link") if @note.update
      end
    end
  end
end

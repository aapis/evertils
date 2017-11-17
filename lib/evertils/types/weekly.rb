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
        # parse the ENML note data into something we can work with
        xml = @api.from_str(@entity.content)
        # include the XML element builder
        xml_helper = Evertils::Helper.load('Xml', xml)
        # find the note entity we want to link
        linked_note = @note_helper.wait_for(:Daily).entity

        # don't add the note link if it is already there
        unless xml.search("a[href='#{@note_helper.internal_url_for(linked_note)}']").size.zero?
          return Notify.warning('Daily note link already exists here, exiting to avoid duplicate content')
        end

        a = xml_helper.a(
          @note_helper.internal_url_for(linked_note),
          @format.date_templates[:Daily]
          )
        li = xml_helper.li(a)
        br = xml_helper.br

        xml.search('en-note>div:first-child>ul li:last-child').after(li)

        # add a line break after the UL if one is not there yet
        if xml.search('en-note>div:first-child').first.next_element.name != 'br'
          xml.search('en-note>div:first-child').after(br)
        end

        @entity.content = xml.to_s

        Notify.success("#{self.class.name} updated, added daily note link") if @note.update
      end
    end
  end
end

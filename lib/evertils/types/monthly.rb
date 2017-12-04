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

        @note = @note_helper.find_note(NOTEBOOK)
        @entity = @note.entity
        result = @entity.nil? && today_is_first_of_month

        Notify.warning "#{self.class.name} skipped, note already exists" unless result

        result
      end

      #
      # @since 0.3.15
      def add_weekly_note_link
        wk_entity = @note_helper.wait_for(:Weekly).entity
        # parse the ENML note data into something we can work with
        xml = @api.from_str(@entity.content)
        # include the XML element builder
        xml_helper = Evertils::Helper.load('Xml', xml)
        # internal URL for the linked note
        note_url = @note_helper.internal_url_for(wk_entity)

        # don't add the note link if it is already there
        unless xml.search("a[href='#{note_url}']").size.zero?
          return Notify.warning('Weekly note link already exists here, exiting to avoid duplicate content')
        end

        a = xml_helper.a(
          note_url,
          @format.date_templates[:Weekly]
        )
        li = xml_helper.li(a)
        br = xml_helper.br

        xml.search('ul:first-child li').after(li)

        # add a line break after the UL if one is not there yet
        if xml.search('ul:first-child').first.next_element.name != 'br'
          xml.search('ul:first-child').after(br)
        end

        @entity.content = xml.to_s

        Notify.success("#{self.class.name} updated, added weekly note link") if @note.update
      end
    end
  end
end

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

        @note = find_note(NOTEBOOK)
        @entity = @note.entity
        result = @note.nil? && today_is_first_of_month

        Notify.warning "#{self.class.name} skipped, note already exists" unless result

        result
      end

      #
      # @since 0.3.15
      def add_weekly_note_link
        xml = @api.from_str(@entity.content)
        xml_helper = Evertils::Helper.load('Xml', xml)

        a = xml_helper.a(
          internal_url_for(@entity),
          @format.date_templates[:Weekly]
          )
        li = xml_helper.li(a)
        br = xml_helper.br

        xml.search('ul:first-child li').after(li)

        # add a line break after the UL if one is not there yet
        if xml.search('ul:first-child').first.next_element.name != 'br'
          xml.search('ul:first-child').after(br)
        end

        @entity.content = xml.to_s.delete!("\n")

        Notify.success("#{self.class.name} updated, added weekly note link") if @note.update
      end
    end
  end
end

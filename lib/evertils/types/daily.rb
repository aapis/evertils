module Evertils
  module Type
    class Daily < Type::Base
      NOTEBOOK = :Daily
      COLOUR = 0xffe8b7

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @title = @format.date_templates[NOTEBOOK]
        @content = @format.template_contents(NOTEBOOK)

        attach_pq_note if morning_note?
      end

      #
      # @since 0.3.9
      def tags
        [
          "day-#{Date.today.yday}",
          "week-#{Date.today.cweek}",
          "month-#{Date.today.month}"
        ]
      end

      private

      #
      # TODO: refactor
      # @since 0.3.13
      def attach_pq_note
        @api = Evertils::Helper.load('ApiEnmlHandler', @config)
        enml = @api.from_str(@format.template_contents(NOTEBOOK))

        pq = @note_helper.wait_for(:'Priority Queue')

        xml_conf = {
          href: @note_helper.internal_url_for(pq.entity),
          content: @format.date_templates[:'Priority Queue']
        }

        xml = Evertils::Helper.load('Xml', enml)
        a = xml.create(:a, xml_conf)

        enml.at('li:contains("Queue") ul li').children.first.replace(a)
        @content = enml
      end
    end
  end
end

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
        ["day-#{Date.today.yday}"]
      end

      private

      #
      # @since 0.3.13
      def morning_note?
        !caller.grep(/morning/).nil?
      end

      #
      # TODO: refactor
      # @since 0.3.13
      def attach_pq_note
        @api = Evertils::Helper.load('ApiEnmlHandler', @config)
        enml = @api.from_str(@format.template_contents(NOTEBOOK))

        pq = find_priority_queue

        # didn't find the note the first time?  wait and try again
        if pq.entity.nil?
          iter = 0
          loop do
            iter += 1
            pq = find_priority_queue(true)
            break unless pq.entity.nil?
          end

          Notify.info("#{iter} attempts to find the pq note") unless iter.zero?
        end

        guid = pq.entity.guid
        user = @model.user_info[:user]
        shard = @model.user_info[:shard]

        a = Nokogiri::XML::Node.new('a', enml)
        a['href'] = "evernote:///view/#{user[:id]}/#{shard}/#{guid}/#{guid}/"
        a.content = @format.date_templates[:'Priority Queue']

        enml.at('li:contains("Queue") ul li').children.first.replace(a)
        @content = enml
      end

      def find_priority_queue(sleep = false)
        sleep(5) if sleep
        title = @format.date_templates[:'Priority Queue']
        @model.find_note_contents(title)
      end
    end
  end
end

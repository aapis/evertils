module Evertils
  module Type
    class PriorityQueue < Type::Base
      NOTEBOOK = :'Priority Queue'
      COLOUR = 0xffe8b7

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @handler = Evertils::Helper.load('ApiEnmlHandler', @config)
        @title = @format.date_templates[NOTEBOOK]
        @content = find_previous
      end

      #
      # @since 0.3.9
      def tags
        ["day-#{Date.today.yday}"]
      end

      private

      # Find a previous note
      # @since 0.3.7
      def find_previous
        day = Date.today
        note = nil

        Notify.info('Searching for...')

        (1..MAX_SEARCH_SIZE).each do |iter|
          day -= 1
          dow = @format.day_of_week(day.strftime('%a'))

          # always skip weekends, even if there is a note for those days
          next if %i[Sa Su].include?(dow)

          note_title = "Queue For [#{day.strftime('%B %-d')} - #{dow}]"
          note = @note_helper.model.find_note_contents(note_title).entity

          Notify.info(" (#{iter}) #{note_title}")

          break unless note.nil?
        end

        raise 'Queue was not found' unless note

        @handler.convert_to_xml(note.content).prepare
      end
    end
  end
end

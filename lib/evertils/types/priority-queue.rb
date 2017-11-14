module Evertils
  module Type
    class PriorityQueue < Type::Base
      NOTEBOOK = :'Priority Queue'
      COLOUR = 0xffe8b7
      MAX_SEARCH_SIZE = 21

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @handler = Evertils::Helper.load('ApiEnmlHandler', @config)
        @title = @format.date_templates[NOTEBOOK]

        if Date.today.monday?
          @content = condition_monday
        elsif Date.today.tuesday?
          @content = condition_tuesday
        else
          @content = condition_default
        end
      end

      #
      # @since 0.3.9
      def tags
        ["day-#{Date.today.yday}"]
      end

      private

      # Get friday's note
      # @since 0.3.7
      def condition_monday
        friday = (Date.today - 3)
        dow = @format.day_of_week(friday.strftime('%a'))
        note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(note_title)

        raise "Queue was not found - #{friday.strftime('%B %-d')}" unless found

        @handler.convert_to_xml(found.entity.content).prepare
      end

      # Find monday's note
      # TODO: refactor
      # @since 0.3.7
      def condition_tuesday
        # get monday note
        monday = (Date.today - 1)
        dow = @format.day_of_week(monday.strftime('%a'))
        monday_note_title = "Queue For [#{monday.strftime('%B %-d')} - #{dow}]"
        monday_note = @model.find_note_contents(monday_note_title)

        if !monday_note.entity.nil?
          note = monday_note.entity
        else
          # if it does not exist, get friday's note
          friday = (Date.today - 4)
          dow = @format.day_of_week(friday.strftime('%a'))
          fri_note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
          fri_note = @model.find_note_contents(fri_note_title)

          if fri_note.entity.nil?
            # if it does not exist, get $day - 1 note until we find one
            day = friday
            iter = 0

            Notify.info('Searching for...')

            loop do
              iter += 1
              day -= 1
              dow = @format.day_of_week(day.strftime('%a'))
              note_title = "Queue For [#{day.strftime('%B %-d')} - #{dow}]"
              query = @model.find_note_contents(note_title)
              note = query.entity

              Notify.info(" (#{iter}) #{note_title}")

              break unless note.nil? || iter == MAX_SEARCH_SIZE
            end
          end
        end

        raise 'Queue was not found' unless note

        @handler.convert_to_xml(note.content).prepare
      end

      # Default action for not-Monday/Tuesday
      # @since 0.3.7
      def condition_default
        yest = (Date.today - 1)
        dow = @format.day_of_week(yest.strftime('%a'))
        yest_note_title = "Queue For [#{yest.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(yest_note_title).entity

        raise "Queue was not found - #{yest.strftime('%B %-d')}" unless found

        @handler.convert_to_xml(found.content).prepare
      end
    end
  end
end

module Evertils
  module Type
    class PriorityQueue < Type::Base
      NOTEBOOK = :'Priority Queue'

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @handler = Evertils::Helper.load('ApiEnmlHandler', @config)

        if Date.today.monday?
          @title, @content = condition_monday
        elsif Date.today.tuesday?
          @title, @content = condition_tuesday
        else
          @title, @content = condition_default
        end
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

        [
          @format.date_templates[NOTEBOOK],
          @handler.convert_to_xml(found.entity.content).prepare
        ]
      end

      # Find monday's note
      # @since 0.3.7
      def condition_tuesday
        monday = (Date.today - 1)
        dow = @format.day_of_week(monday.strftime('%a'))
        monday_note_title = "Queue For [#{monday.strftime('%B %-d')} - #{dow}]"
        monday_note = @model.find_note_contents(monday_note_title)

        if !monday_note.entity.nil?
          note = monday_note.entity
          note.title = @format.date_templates[NOTEBOOK]
        else
          # if it does not exist, get friday's note
          friday = (Date.today - 4)
          dow = @format.day_of_week(friday.strftime('%a'))
          note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
          note = @model.find_note_contents(note_title)
        end

        raise 'Queue was not found' unless note

        [
          note.title,
          @handler.convert_to_xml(note.content).prepare
        ]
      end

      # Default action for not-Monday/Tuesday
      # @since 0.3.7
      def condition_default
        yest = (Date.today - 1)
        dow = @format.day_of_week(yest.strftime('%a'))
        yest_note_title = "Queue For [#{yest.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(yest_note_title).entity

        raise "Queue was not found - #{yest.strftime('%B %-d')}" unless found

        [
          @format.date_templates[NOTEBOOK],
          @handler.convert_to_xml(found.content).prepare
        ]
      end
    end
  end
end

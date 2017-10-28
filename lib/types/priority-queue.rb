module Evertils
  module Type
    class PriorityQueue < Type::Base
      attr_reader :title, :content, :notebook

      NOTEBOOK = :'Priority Queue'

      #
      # @since 0.3.7
      def initialize
        super

        if Date.today.monday?
          @title, @content = condition_monday
        elsif Date.today.tuesday?
          @title, @content = condition_tuesday
        else
          @title, @content = condition_default
        end
      end

      #
      # @since 0.3.7
      def notebook
        NOTEBOOK
      end

      private

      #
      # @since 0.3.7
      def condition_monday
        # get friday's note
        friday = (Date.today - 3)
        dow = @format.day_of_week(friday.strftime('%a'))
        note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(note_title)

        raise "Queue was not found - #{friday.strftime('%B %-d')}" unless found

        [
          @format.date_templates[NOTEBOOK],
          Helper::Enml.new(found.entity.content).prepare
        ]
      end

      #
      # @since 0.3.7
      def condition_tuesday
        # find monday's note
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
          Helper::Enml.new(note.content).prepare
        ]
      end

      #
      # @since 0.3.7
      def condition_default
        yest = (Date.today - 1)
        dow = @format.day_of_week(yest.strftime('%a'))
        yest_note_title = "Queue For [#{yest.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(yest_note_title).entity

        raise "Queue was not found - #{yest.strftime('%B %-d')}" unless found

        [
          @format.date_templates[NOTEBOOK],
          Helper::Enml.new(found.content).prepare
        ]
      end
    end
  end
end
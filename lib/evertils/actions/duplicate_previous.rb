# frozen_string_literal: true

module Evertils
  module Action
    class DuplicatePrevious < Action::Base
      def initialize(args)
        super(args)

        @args[:content] = find_previous(args)

        query = Evertils::Common::Query::Simple.new
        query.create_note_from_hash(@args)
      end

      private

      def find_previous(args)
        day = Date.today
        note = nil

        Notify.info("Searching for last #{@args[:notebook]}...")

        (1..Evertils::Type::Base::MAX_SEARCH_SIZE).each do |iter|
          day -= 1
          dow = day.strftime('%a')

          # always skip weekends, even if there is a note for those days
          next if %i[Sat Sun].include?(dow)

          note_title = @args[:title]
          note = @note_helper.model.find_note_contents(note_title).entity

          Notify.info(" (#{iter}) #{note_title}")

          break unless note.nil?
        end

        @api.convert_to_xml(note.content).prepare
      end
    end
  end
end

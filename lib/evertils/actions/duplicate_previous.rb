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

        (1..Evertils::Base::MAX_SEARCH_SIZE).each do |iter|
          day -= 1
          dow = day.strftime('%a')

          # always skip weekends, even if there is a note for those days
          next if %i[Sat Sun].include?(dow)

          note_title = previous_note_title(@args[:title_format], day)
          note = @note_helper.model.find_note_contents(note_title).entity

          Notify.info(" (#{iter}) #{note_title}")

          break unless note.nil?
        end

        @api.convert_to_xml(note.content).prepare
      end

      def previous_note_title(fmt, date)
        # not a good solution but it works
        # TODO: fix this
        replacements = {
          '%DOY%': date.yday,
          '%MONTH_NAME%': date.strftime('%B'),
          '%MONTH%': date.month,
          '%DAY%': date.day,
          '%DOW%': date.wday,
          '%DOW_NAME%': date.strftime('%a'),
          '%YEAR%': date.year,
          '%WEEK%': date.cweek,
          '%WEEK_START%': Date.commercial(date.year, date.cweek, 1),
          '%WEEK_END%': Date.commercial(date.year, date.cweek, 5)
        }

        title_format = fmt.dup

        replacements.each_pair { |k, v| title_format.gsub!(k.to_s, v.to_s) }
        title_format
      end
    end
  end
end

# frozen_string_literal: true

module Evertils
  module Action
    class DuplicatePrevious < Action::Base
      def initialize(args)
        super(args)

        @args.content = find_previous

        query = Evertils::Common::Query::Simple.new
        query.create_note_from_hash(@args.to_h)
      end

      private

      def find_previous
        helper = Evertils::Helper::Note.instance
        note = helper.wait_for_with_grammar(grammar)

        @api.convert_to_xml(note.entity.content).prepare
      end

      def grammar
        terms = Grammar.new
        terms.notebook = @args[:notebook]
        terms.tags = {
          day: Date.today.yday,
          week: Date.today.cweek
        }
        terms.created = Date.new(Date.today.year, 1, 1).strftime('%Y%m%d')
        terms
      end
    end
  end
end

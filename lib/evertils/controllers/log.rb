# frozen_string_literal: true

module Evertils
  module Controller
    Formatting = Evertils::Helper::Formatting

    class Log < Controller::Base
      WORDS_PER_LINE = 20

      def pre_exec
        super

        @note = nil
        @note_helper = Evertils::Helper::Note.instance
        @api_helper = Evertils::Helper::ApiEnmlHandler.new(@config)
      end

      # Send arbitrary text to the daily log
      def message(text = nil)
        return Notify.error('A message is required') if text.nil?

        @note = @note_helper.find_note_by_grammar(grammar.to_s)
        text_groups = text.split(' ').each_slice(WORDS_PER_LINE).map do |w|
          w.join(' ')
        end

        return Notify.error('Note not found') if @note.entity.nil?

        modify_with(text_groups)
      end

      #
      # @since 2.2.0
      def grep(text = nil)
        params = OpenStruct.new(term: text, action: 'search', notebook: 'Daily')

        runner = ActionRunner.new
        runner.params = params
        runner.execute
      end

      #
      # @since 2.2.0
      def group
        params = OpenStruct.new(action: 'group', notebook: 'Daily')

        runner = ActionRunner.new
        runner.params = params
        runner.execute
      end

      private

      def grammar
        terms = Grammar.new
        terms.tags = {
          day: Date.today.yday,
          week: Date.today.cweek
        }
        terms.notebook = :Daily
        terms.created = Date.new(Date.today.year, 1, 1).strftime('%Y%m%d')
        terms
      end

      # Update a note with content
      def modify_with(text)
        xml = update_note_content_with(text)

        # remove XML processing definition if it is the second element
        if xml.children[1].is_a?(Nokogiri::XML::ProcessingInstruction)
          xml.children[1].remove
        end

        @note.entity.content = xml.to_s

        Notify.success("Item logged at #{Formatting.current_time}") if @note.update
      end

      #
      # @since 2.2.1
      def update_note_content_with(text)
        xml = @api_helper.from_str(@note.entity.content)
        target = xml.search('en-note').first

        text.each do |line|
          target.add_child("<div>* #{Formatting.current_time} - #{Formatting.clean(line)}</div>")
        end

        xml
      end
    end
  end
end

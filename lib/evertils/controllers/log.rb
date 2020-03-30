module Evertils
  module Controller
    class Log < Controller::Base
      def pre_exec
        super

        @note_helper = Evertils::Helper::Note.instance
        @api_helper = Evertils::Helper::ApiEnmlHandler.new(@config)
      end

      # Send arbitrary text to the daily log
      def message(text = nil)
        return Notify.error('A message is required') if text.nil?

        note = @note_helper.find_note_by_grammar(grammar.to_s)

        return Notify.error('Note not found') if note.entity.nil?

        modify(note, text)
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
      def modify(note, text)
        xml = @api_helper.from_str(note.entity.content)

        time = Time.now.strftime('%I:%M')
        target = xml.search('en-note').first

        return Notify.error('Unable to log message, triage section not found') if target.nil?

        log_message_txt = "<div>* #{time} - #{text}</div>"

        # append the log message to the target
        target.add_child(log_message_txt)

        # remove XML processing definition if it is the second element
        if xml.children[1].is_a?(Nokogiri::XML::ProcessingInstruction)
          xml.children[1].remove
        end

        note.entity.content = xml.to_s

        Notify.success("Item logged at #{time}") if note.update
      end
    end
  end
end

module Evertils
  module Controller
    class Log < Controller::Base
      def pre_exec
        super

        @note_helper = Evertils::Helper.load('Note')
        @api_helper = Evertils::Helper.load('ApiEnmlHandler', @config)
      end

      # Send arbitrary text to the daily log
      def message(text = nil)
        return Notify.error('A message is required', {}) if text.nil?

        note = @note_helper.wait_for_by_notebook(:Daily)

        return Notify.error('Note not found') if note.entity.nil?

        modify(note, text)
      end

      private

      # Update a note with content
      def modify(note, text)
        xml = @api_helper.from_str(note.entity.content)

        time = Time.now.strftime('%I:%M')
        target = xml.search('en-note>div').first

        return Notify.error('Unable to log message, triage section not found') if target.nil?

        log_message_txt = "* #{time} - #{text}<br clear='none'/>"

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

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

        note = @note_helper.wait_for(:Daily)
        edit_conf = {
          search: 'Triage',
          append: text
        }

        return Notify.error("Note not found") if note.entity.nil?

        modify(note, edit_conf)
      end

      private

      # Update a note with content
      def modify(note, conf)
        xml = @api_helper.from_str(note.entity.content)
        xml_helper = Evertils::Helper.load('Xml', xml)

        time = Time.now.strftime('%I:%M')
        target = xml.search("div:contains('#{conf[:search]}')").first.next_element

        return Notify.error('Unable to log message') if target.nil?

        log_message_txt = xml_helper.span("#{time} - #{conf[:append]}")
        log_message_el = xml_helper.li(log_message_txt)

        # append the log message to the target
        target.add_child(log_message_el)

        note.entity.content = xml.to_s
        Notify.success("Item logged at #{time}") if note.update
      end
    end
  end
end

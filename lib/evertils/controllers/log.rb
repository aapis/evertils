module Evertils
  module Controller
    class Log < Controller::Base
      def pre_exec
        super

        @note_helper = Evertils::Helper.load('Note')
        @api_helper = Evertils::Helper.load('ApiEnmlHandler', {})
      end

      # Send arbitrary text to the daily log
      def message(text)
        Notify.error('Text argument is required', {}) if text.nil?

        note = @note_helper.wait_for(:Daily)
        edit_conf = {
          search: 'Triage',
          append: text
        }

        modify(note, edit_conf)
      end

      private

      # Update a note with content
      def modify(note, conf)
        xml = @api_helper.from_str(note.entity.content)
        xml_helper = Evertils::Helper.load('Xml', xml)

        time = Time.now.strftime('%I:%M')
        target = xml.search("div:contains('#{conf[:search]}')").first.next_element
        nearest_ul = target.search('ul')
        span = xml_helper.span("#{time} - #{conf[:append]}")
        li = xml_helper.li(span)

        if nearest_ul.empty?
          node = xml_helper.ul(li)
          if target.children.size.zero?
            node << target.children
          else
            target.children.before(node)
          end
        else
          nearest_ul.children.after(li)
        end
        puts xml.to_s
        note.entity.content = xml.to_s
        Notify.success("Item logged at #{time}") if note.update
      end
    end
  end
end
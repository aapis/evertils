# frozen_string_literal: true

module Evertils
  module Controller
    Formatting = Evertils::Helper::Formatting

    class Log < Controller::Base
      WORDS_PER_LINE = 20

      # Each row we log or read from the log
      Row = Struct.new(:time, :text, :job)

      def pre_exec
        super

        @note = nil
        @text = nil
        @rows = []
        @note_helper = Evertils::Helper::Note.instance
        @api_helper = Evertils::Helper::ApiEnmlHandler.new(@config)
      end

      # Send arbitrary text to the daily log
      def message(text = nil)
        return Notify.error('A message is required') if text.nil?

        @text = text

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

      def at(time, text = ARGV[3])
        return Notify.error('A message is required') if text.nil?
        return Notify.error('A time is required') if time.nil?

        @note = @note_helper.find_note_by_grammar(grammar.to_s)
        xml = update_note_content_with(Row.new(log_time, chunk(text), 11))
        rows = []

        xml.search('div').each do |div|
          h, m = div.text.scan(/^\* (\d+)\:(\d+) -/).first
          job = div.text.scan(/^\* \d+\:\d+ - (\d+) - /).first.first.to_i
          text = div.text.scan(/^\* \d+\:\d+ - \d* - (.*)$/).first.first

          rows.push(Row.new(timestamp_from(h, m), text, job))
        end

        rows.sort_by!(&:time)

        # covert the array of structs to a text string which can be passed to
        # target.add_child
        rows.each do |line|
          child = "<div>* #{line.time.strftime('%H:%M')} -".dup
          child.concat " #{line.job} -"
          child.concat " #{line.text}</div>"
          # target.add_child(child)
          puts child.inspect
        end
      end

      private

      def chunk(text)
        text.split(' ').each_slice(WORDS_PER_LINE).map { |w| w.join(' ') }
      end

      def text_groups
        @note = @note_helper.find_note_by_grammar(grammar.to_s)
        groups = @text.split(' ').each_slice(WORDS_PER_LINE).map do |w|
          w.join(' ')
        end

        return Notify.error('Note not found') if @note.entity.nil?

        groups
      end

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

        return Notify.success("Item logged at #{Formatting.current_time}") if @note.update

        Notify.error('Error logging item')
      end

      #
      # @since 2.2.1
      def update_note_content_with(row)
        raise 'Must be an instance of Row' unless row.is_a? Row

        xml = @api_helper.from_str(@note.entity.content)
        target = xml.search('en-note').first
        job_id = 0
        job_id = row.text.first.split(' -').first.to_i unless row.text.first.scan('-').empty?

        row.text.map! { |l| l.gsub("#{job_id} - ", '') }

        row.text.each do |line|
          child = "<div>* #{log_time} -".dup
          child.concat " #{job_id} -" unless job_id.zero?
          child.concat " #{Formatting.clean(line)}</div>"
          target.add_child(child)
        end

        xml
      end

      def log_time
        return Formatting.current_time if @time.nil?

        h, m = @time.split(':').map(&:to_i)

        timestamp_from(h, m)
      end

      def timestamp_from(hour, minute)
        now = Date.today

        DateTime.new(now.year, now.month, now.day, hour.to_i, minute.to_i, 0, 0)
      end
    end
  end
end

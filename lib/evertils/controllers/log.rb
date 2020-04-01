module Evertils
  module Controller
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
        return Notify.error('A search term is required') if text.nil?

        @note = @note_helper.find_note_by_grammar(grammar.to_s)

        return Notify.error('Note not found') if @note.entity.nil?

        search_for(text)
      end

      #
      # @since 2.2.0
      def group(text = nil)
        @note = @note_helper.find_note_by_grammar(grammar.to_s)

        return Notify.error('Note not found') if @note.entity.nil?

        group_by
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

        Notify.success("Item logged at #{current_time}") if @note.update
      end

      #
      # @since 2.2.1
      def update_note_content_with(text)
        xml = @api_helper.from_str(@note.entity.content)
        target = xml.search('en-note').first

        text.each do |line|
          target.add_child("<div>* #{current_time} - #{clean(line)}</div>")
        end

        xml
      end

      #
      # @since 2.2.0
      def search_for(text)
        results = grep_results_for(text)

        return Notify.error("No rows matched search query {#{text}}") if results.empty?

        Notify.success("#{results.size} rows matched query {#{text}}")
        results.each { |res| Notify.info(clean(res)) }
      end

      #
      # @since 2.2.0
      def group_by
        grouped_results.each_pair do |job_id, rows|
          Notify.note("#{clean(job_id)} - #{rows.size} occurrences") unless job_id.nil?

          rows.each { |row| Notify.info(clean(row)) }
        end
      end

      #
      # @since 2.2.0
      def search_nodes
        xml = @api_helper.from_str(@note.entity.content)
        target = xml.search('en-note').first
        nodes = []

        target.children.each do |child|
          node = child.children.first.to_s
          nodes.push(clean(node)) unless node.empty? || node == '<br/>'
        end

        nodes
      end

      #
      # @since 2.2.0
      def grouped_results
        search_nodes.group_by do |node|
          match = /- (.*)? -/.match(node)
          match[1] unless match.nil?
        end
      end

      #
      # @since 2.2.0
      def grep_results_for(text)
        search_nodes.select { |line| line.include? text }
      end

      #
      # @since 2.2.0
      def clean(text)
        text.delete("\n").gsub('&#xA0;', ' ')
      end

      def current_time
        Time.now.strftime('%I:%M')
      end
    end
  end
end

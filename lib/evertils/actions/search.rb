# frozen_string_literal: true

module Evertils
  module Action
    class Search < Action::Base
      def initialize(args)
        @note_helper = Evertils::Helper::Note.instance
        @args = args
        @note = @note_helper.find_note_by_grammar(grammar.to_s)
        @api_helper = Evertils::Helper::ApiEnmlHandler.new(@config)

        execute
      end

      private

      def execute
        return Notify.error('Note not found') if @note.entity.nil?

        search_for(@args.term)
      end

      def grammar
        terms = Grammar.new
        terms.tags = {
          day: Date.today.yday,
          week: Date.today.cweek
        }
        terms.notebook = @args.notebook
        terms.created = Date.new(Date.today.year, 1, 1).strftime('%Y%m%d')
        terms
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
      def grep_results_for(text)
        return search_nodes.select { |line| line.scan(text) } if text.is_a? Regexp

        search_nodes.select { |line| line.include? text }
      end

      #
      # @since 2.2.0
      def clean(text)
        text.delete("\n").gsub('&#xA0;', ' ')
      end

      #
      # @since 2.2.1
      def current_time
        Time.now.strftime('%I:%M')
      end
    end
  end
end

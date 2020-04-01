# frozen_string_literal: true

module Evertils
  module Action
    class Search < Action::Base
      Formatting = Evertils::Helper::Formatting

      #
      # @since 2.2.2
      def initialize(args)
        @note_helper = Evertils::Helper::Note.instance
        @args = args
        @note = @note_helper.find_note_by_grammar(grammar.to_s)
        @api_helper = Evertils::Helper::ApiEnmlHandler.new(@config)

        execute
      end

      private

      #
      # @since 2.2.2
      def execute
        return Notify.error('Note not found') if @note.entity.nil?

        search_for(@args.term)
      end

      #
      # @since 2.2.2
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
      # @since 2.2.2
      def search_for(text)
        results = grep_results_for(text)

        return Notify.error("No rows matched search query {#{text}}") if results.empty?

        Notify.success("#{results.size} rows matched query {#{text}}")
        results.each { |res| Notify.info(Formatting.clean(res)) }
      end

      #
      # @since 2.2.2
      def search_nodes
        xml = @api_helper.from_str(@note.entity.content)
        target = xml.search('en-note').first
        nodes = []

        target.children.each do |child|
          node = child.children.first.to_s
          nodes.push(Formatting.clean(node)) unless node.empty? || node == '<br/>'
        end

        nodes
      end

      #
      # @since 2.2.2
      def grep_results_for(text)
        return search_nodes.select { |line| line.scan(text) } if text.is_a? Regexp

        search_nodes.select { |line| line.include? text }
      end
    end
  end
end

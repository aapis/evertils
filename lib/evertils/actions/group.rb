# frozen_string_literal: true

module Evertils
  module Action
    class Group < Action::Base
      Formatting = Evertils::Helper::Formatting

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

        group_by
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
      def group_by
        grouped_results.each_pair do |job_id, rows|
          Notify.note("#{Formatting.clean(job_id)} - #{rows.size} occurrences") unless job_id.nil?

          rows.each { |row| Notify.info(Formatting.clean(row)) }
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
          nodes.push(Formatting.clean(node)) unless node.empty? || node == '<br/>'
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
    end
  end
end

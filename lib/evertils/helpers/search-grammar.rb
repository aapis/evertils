module Evertils
  module Helper
    class SearchGrammar
      def from(conf)
        @configuration = conf
        @grammar = []

        fix_standard_grammar
        fix_tags if @configuration.include?(:tags)

        @grammar.join(' ')
      end

      private

      def fix_tags
        @configuration[:tags].each_pair do |k, v|
          @grammar.push("tag:#{k}-#{v}")
        end
      end

      def fix_standard_grammar
        @configuration.each_pair do |k, v|
          @grammar.push("#{k}:#{v}") unless k == :tags
        end
      end
    end
  end
end
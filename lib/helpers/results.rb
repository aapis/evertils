module Granify
  module Helper
    class Results
      attr_reader :bucket
      def initialize
        @bucket = []
        @bucket
      end

      # Add a result for processing
      def add(result)
        @bucket.push(result.to_bool)
        result.to_bool
      end

      def should_eval_to(pass_value)
        @bucket.all? == pass_value
      end
    end
  end
end
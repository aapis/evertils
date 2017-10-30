module Evertils
  module Type
    class MonthlyTaskSummary < Type::Base
      NOTEBOOK = :'Monthly Task Summaries'

      #
      # @since 0.3.7
      def initialize(config, *args)
        super(config, *args)

        @name = @args.first
        @title = "#{@name} #{DateTime.now.strftime('%m-%Y')}"
        @content = @format.template_contents(NOTEBOOK)
      end

      #
      # @since 0.3.9
      def tags
        ["day-#{Date.today.yday}", @args.first]
      end
    end
  end
end
module Evertils
  module Controller
    class Status < Controller::Base
      attr_accessor :force, :start

      def pre_exec
        # all methods require internet to make API calls
        #@methods_require_internet.push(:daily, :weekly, :monthly, :deployment)

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-f", "--force", "Force execution") do
            @force = true
          end

          opt.on("-s", "--start=START", "Specify a date for the note") do |date|
            @start = DateTime.parse(date)
          end
        end.parse!

        super
      end

      def default
        $config.options.each_pair do |key, value|
          puts "#{key}: #{value}"
        end
      end
    end
  end
end

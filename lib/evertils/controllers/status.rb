module Evertils
  module Controller
    class Status < Controller::Base

      def default
        $config.options.each_pair do |key, value|
          puts "#{key}: #{value}"
        end
      end

    end
  end
end

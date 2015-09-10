module Granify
  module StatsProcessor
    class TimeStats
      def calculate_averages(type, notes)
        notes.each do |note|
          puts note.inspect
          exit
        end
      end
    end
  end
end
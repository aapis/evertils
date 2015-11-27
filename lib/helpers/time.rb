module Evertils
  module Helper
    class Time
      def self.human_readable(start, finish)
        seconds = finish.to_f - start.to_f

        if seconds < 60
          "No time at all!"
        else
          minutes = (seconds / 60).round(1)
          if minutes < 1
            "#{minutes} minute"
          else
            "#{minutes} minutes"
          end
        end
      end

      def self.formatted(time = nil)
        if time.nil?
          time = ::Time.now
        end
        
        time.strftime("%e/%-m/%Y @ %I:%M:%S%P")
      end
    end
  end
end

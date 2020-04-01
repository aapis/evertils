# frozen_string_literal: true

module Evertils
  module Helper
    class Formatting
      # Template string for note title
      def self.date_templates
        current_date = Date.today
        week_stub = current_date.strftime('%a')
        start_of_week = Date.commercial(current_date.year, current_date.cweek, 1)
        end_of_week = Date.commercial(current_date.year, current_date.cweek, 5)

        {
          :Daily => "Daily Log [#{current_date.strftime('%B %-d')} - #{week_stub}]",
          :Weekly => "Weekly Log [#{start_of_week.strftime('%B %-d')} - #{end_of_week.strftime('%B %-d')}]",
          :Monthly => "Monthly Log [#{current_date.strftime('%B %Y')}]",
          :Deployments => "#{current_date.strftime('%B %-d')} - #{week_stub}",
          :'Priority Queue' => "Queue For [#{current_date.strftime('%B %-d')} - #{week_stub}]"
        }
      end

      def self.symbolize_keys(hash)
        hash.inject({}){ |result, (key, value)|
          new_key = case key
                    when String then key.to_sym
                    else key
                    end
          new_value = case value
                      when Hash then symbolize_keys(value)
                      else value
                      end
          result[new_key] = new_value
          result
        }
      end

      #
      # @since 2.2.0
      def self.clean(text)
        text.delete("\n").gsub('&#xA0;', ' ')
      end

      #
      # @since 2.2.1
      def self.current_time
        Time.now.strftime('%I:%M')
      end
    end
  end
end

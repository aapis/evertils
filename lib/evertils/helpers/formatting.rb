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
    end
  end
end

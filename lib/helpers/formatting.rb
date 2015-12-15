module Evertils
  module Helper
    class Formatting
      # Legacy notes will have single/double character denotations for day of
      # week, this maps them.
      def day_of_week(arg_date = Date.today.strftime('%a'))
        case arg_date
        when 'Mon'
          :M
        when 'Tue'
          :Tu
        when 'Wed'
          :W
        when 'Thu'
          :Th
        when 'Fri'
          :F
        when 'Sat'
          :Sa
        when 'Sun'
          :Su
        end
      end

      def template_contents
        if Date.today.friday? && command == :Daily
          # Friday uses a slightly different template
          IO.readlines("#{Evertils::TEMPLATE_DIR}#{command}-friday.enml").join("").gsub!("\n", '')
        else
          IO.readlines("#{Evertils::TEMPLATE_DIR}#{command}.enml").join("").gsub!("\n", '')
        end
      end

      def date_templates(arg_date = DateTime.now)
        dow = day_of_week(arg_date.strftime('%a'))
        end_of_week = arg_date + 4 # days
        
        {
          :Daily => "Daily Log [#{arg_date.strftime('%B %-d')} - #{dow}]",
          :Weekly => "Weekly Log [#{arg_date.strftime('%B %-d')} - #{end_of_week.strftime('%B %-d')}]",
          :Monthly => "Monthly Log [#{arg_date.strftime('%B %Y')}]",
          :Deployments => "#{arg_date.strftime('%B %-d')} - #{dow}"
        }
      end

      # format command as required by this model
      def command
        $request.command.capitalize
      end
    end
  end
end

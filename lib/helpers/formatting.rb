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

      # Template file for note body
      def template_contents(type = nil)
        begin
          raise ArgumentError, "Type is required" if type.nil?

          IO.readlines(load_template(type), :encoding => 'UTF-8').join("").delete!("\n")
        rescue Errno::ENOENT => e
          Notify.error(e.message)
        rescue ArgumentError => e
          Notify.error(e.message)
        end
      end

      # Template string for note title
      def date_templates(arg_date = DateTime.now)
        dow = day_of_week(arg_date.strftime('%a'))
        end_of_week = arg_date + 4 # days

        {
          :Daily => "Daily Log [#{arg_date.strftime('%B %-d')} - #{dow}]",
          :Weekly => "Weekly Log [#{arg_date.strftime('%B %-d')} - #{end_of_week.strftime('%B %-d')}]",
          :Monthly => "Monthly Log [#{arg_date.strftime('%B %Y')}]",
          :Deployments => "#{arg_date.strftime('%B %-d')} - #{dow}",
          :'Priority Queue' => "Queue For [#{arg_date.strftime('%B %-d')} - #{dow}]"
        }
      end

      # format command as required by this model
      def command
        $request.command.capitalize
      end

      private

      #
      # @since 0.3.1
      def load_template(type)
        template_type_map = {
          :Daily => "daily",
          :Weekly => "weekly",
          :Monthly => "monthly",
          :"Monthly Task Summaries" => "mts",
          :"Priority Queue" => "pq"
        }

        default = "#{Evertils::TEMPLATE_DIR}#{template_type_map[type]}.enml"

        return default if $config.custom_templates.nil?

        rval = default
        tmpl = $config.custom_templates[type]

        if !tmpl.nil?
          rval = $config.custom_path

          if tmpl.include?('~')
            rval += tmpl.gsub!(/~/, Dir.home)
          else
            rval += tmpl
          end
        end

        rval
      end

    end
  end
end

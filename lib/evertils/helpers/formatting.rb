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
          Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
        rescue ArgumentError => e
          Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
        end
      end

      # Template string for note title
      def date_templates
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

      # Recursively symbolize keys in a hash
      # Params:
      # +h+:: The hash you want to symbolize
      def symbolize(h)
        case h
        when Hash
          Hash[
            h.map do |k, v|
              [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize(v)]
            end
          ]
        when Enumerable
          h.map { |v| symbolize(v) }
        else
          h
        end
      end

      private

      #
      # @since 0.3.1
      def load_template(type)
        file_name = type.to_s.downcase.gsub(/\s/, '-')
        installed_dir = Gem::Specification.find_by_name('evertils').gem_dir
        local_installed_dir = "#{Dir.home}/.evertils/templates/"
        template_file = "#{installed_dir}/lib/evertils/configs/templates/#{file_name}.enml"

        if Dir.exist? local_installed_dir
          template_file = "#{local_installed_dir}#{file_name}.enml"

          # local config dir exists but the requested template does not, use
          # the default template for this type
          unless File.exist? template_file
            template_file = "#{installed_dir}/lib/evertils/configs/templates/#{file_name}.enml"
          end
        end

        template_file
      end
    end
  end
end

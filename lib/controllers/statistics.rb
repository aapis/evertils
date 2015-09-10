require_relative '../stats_processors/time'

module Granify
  module Controller
    class Statistics < Controller::Base
      def pre_exec
        begin
          # interface with the Evernote API so we can use it later
          @evernote = Granify::Helper.load(:evernote)

          # assign various analysis tools to variables
          @time_model = Granify::StatsProcessor.load(:time)

          # all methods require internet to make API calls
          @methods_require_internet.push(:avg_sod, :avg_eod)
        rescue ::Evernote::EDAM::Error::EDAMSystemException => e
          Notify.error("Evernote.authenticate error\n#{e.message} (#{e.errorCode})")
        rescue ::Evernote::EDAM::Error::EDAMUserException => e
          Notify.error("Evernote.authenticate error\n#{e.parameter} (#{e.errorCode})")
        rescue LoadError => e
          Notify.error("#{e.message} (#{e.errorCode})")
        end

        OptionParser.new do |opt|
          opt.banner = "#{Granify::PACKAGE_NAME} statistics type [...-flags]"

          opt.on("-f", "--force", "Force execution") do
            @force = true
          end
        end.parse!

        super
      end

      def avg_sod
        @time_model.calculate_averages(:sod, @evernote.notes_by_notebook(:Daily))
      end

      def avg_eod
        @time_model.calculate_averages(:eod, @evernote.notes_by_notebook(:Daily))
      end
    end
  end
end
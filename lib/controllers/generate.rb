module Granify
  module Controller
    class Generate < Controller::Base
      attr_accessor :force, :start

      def pre_exec
        begin
          # interface with the Evernote API so we can use it later
          @model = Granify::Helper.load('evernote')

          # all methods require internet to make API calls
          @methods_require_internet.push(:daily, :weekly, :monthly, :deployment)

          # user = @model.user
          # Notify.success("Welcome, #{user.name} (#{user.username})")
        rescue ::Evernote::EDAM::Error::EDAMSystemException => e
          Notify.error("Evernote.authenticate error\n#{e.message} (#{e.errorCode})")
        rescue ::Evernote::EDAM::Error::EDAMUserException => e
          Notify.error("Evernote.authenticate error\n#{e.parameter} (#{e.errorCode})")
        end

        OptionParser.new do |opt|
          opt.banner = "#{Granify::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-f", "--force", "Force execution") do
            @force = true
          end

          opt.on("-s", "--start=START", "Specify a date for the note") do |date|
            @start = DateTime.parse(date)
          end
        end.parse!

        super
      end

      def deployment
        if STDIN.tty?
          Notify.error("This command relies on piped data to generate note data")
        end

        if !@force
          if @model.note_exists(@start)
            Notify.error("There's already a log for today!")
          end
        end

        @model.create_deployment_note(@start)
      end

      # generate daily notes
      def daily
        if !@force
          if @model.note_exists
            Notify.error("There's already a log for today!")
          end
        end

        @model.create_note
      end

      # generate weekly notes
      def weekly
        if !@force
          if @model.note_exists
            Notify.error("There's already a log for this week!")
          end


          if !Date.today.monday?
            Notify.error("Sorry, you can only create new weekly logs on Mondays")
          end
        end

        @model.create_note
      end

      # generate monthly notes
      def monthly
        if !@force
          if @model.note_exists
            Notify.error("There's already a log for this month!")
          end
        end

        @model.create_note
      end
    end
  end
end
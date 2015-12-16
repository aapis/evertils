module Evertils
  module Controller
    class Generate < Controller::Base
      attr_accessor :force, :start

      # required user-created notebooks
      NOTEBOOK_DAILY = :Daily
      NOTEBOOK_WEEKLY = :Weekly
      NOTEBOOK_MONTHLY = :Monthly
      NOTEBOOK_DEPLOYMENT = :Deployments

      def pre_exec
        @methods_require_internet.push(:daily, :weekly, :monthly)

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-f", "--force", "Force execution") do
            @force = true
          end

          opt.on("-s", "--start=START", "Specify a date for the note") do |date|
            @start = DateTime.parse(date)
          end
        end.parse!

        super
      end

      # generate daily notes
      def daily
        if !@force
          if @model.note_exists
            Notify.error("There's already a log for today!")
          end
        end

        title = @format.date_templates[NOTEBOOK_DAILY]
        body = @format.template_contents
        parent_notebook = NOTEBOOK_DAILY

        @model.create_note(title, body, parent_notebook)
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

        title = @format.date_templates[NOTEBOOK_WEEKLY]
        body = @format.template_contents
        parent_notebook = NOTEBOOK_WEEKLY

        @model.create_note(title, body, parent_notebook)
      end

      # generate monthly notes
      def monthly
        if !@force
          if @model.note_exists
            Notify.error("There's already a log for this month!")
          end
        end

        title = @format.date_templates[NOTEBOOK_MONTHLY]
        body = @format.template_contents
        parent_notebook = NOTEBOOK_MONTHLY

        @model.create_note(title, body, parent_notebook)
      end
    end
  end
end

module Evertils
  module Controller
    class Generate < Controller::Base
      attr_accessor :force, :start, :name

      # required user-created notebooks
      NOTEBOOK_DAILY = :Daily
      NOTEBOOK_WEEKLY = :Weekly
      NOTEBOOK_MONTHLY = :Monthly
      NOTEBOOK_DEPLOYMENT = :Deployments
      NOTEBOOK_MTS = :'Monthly Task Summaries'

      def pre_exec
        @methods_require_internet.push(:daily, :weekly, :monthly, :mts)

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-f", "--force", "Force execution") do
            @force = true
          end

          opt.on("-s", "--start=START", "Specify a date for the note") do |date|
            @start = DateTime.parse(date)
          end

          opt.on("-n", "--name=NAME", "A name to pass to the script (not all commands support this flag)") do |name|
            @name = name
          end
        end.parse!

        super
      end

      # generate daily notes
      def daily
        title = @format.date_templates[NOTEBOOK_DAILY]
        body = @format.template_contents
        body += to_enml($config.custom_sections[NOTEBOOK_DAILY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_DAILY

        @model.create_note(title: title, body: body, parent_notebook: parent_notebook)
      end

      # generate weekly notes
      def weekly
        title = @format.date_templates[NOTEBOOK_WEEKLY]
        body = @format.template_contents
        body += to_enml($config.custom_sections[NOTEBOOK_WEEKLY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_WEEKLY

        if !@force
          if !Date.today.monday?
            Notify.error("Sorry, you can only create new weekly logs on Mondays", {})
          end
        end

        note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        tag_manager = Evertils::Common::Manager::Tag.instance
        week_tag = tag_manager.find("week-#{DateTime.now.cweek + 1}")
        note.tag(week_tag.prop(:name))
      end

      # generate monthly notes
      def monthly
        title = @format.date_templates[NOTEBOOK_MONTHLY]
        body = @format.template_contents
        body += to_enml($config.custom_sections[NOTEBOOK_MONTHLY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_MONTHLY

        note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        tag_manager = Evertils::Common::Manager::Tag.instance
        month_tag = tag_manager.find("month-#{DateTime.now.strftime('%-m')}")
        note.tag(month_tag.prop(:name))
      end

      # generate monthly task summary templates
      def mts
        Notify.error("Name argument is required", {}) if @name.nil?

        title = "#{@name} #{DateTime.now.strftime('%m-%Y')}"
        body = @format.template_contents
        body += to_enml($config.custom_sections[NOTEBOOK_MTS]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_MTS

        # create the note from template
        mts_note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        # tag it
        # TODO: maybe move this out of controller?
        tag_manager = Evertils::Common::Manager::Tag.instance
        month_tag = tag_manager.find("month-#{DateTime.now.strftime('%-m')}")
        mts_note.tag(month_tag.prop(:name))

        # TODO: commented out until support for multiple tags is added
        # client_tag = tag_manager.find_or_create(@name)
        # mts_note.tag(client_tag.prop(:name))
      end

      private

      #
      # @since 0.3.1
      def to_enml(hash)
        Evertils::Helper::EvernoteENML.with_list(hash)
      end

    end
  end
end

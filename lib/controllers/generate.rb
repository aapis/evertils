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
      NOTEBOOK_PRIORITY_QUEUE = :'Priority Queue'

      def pre_exec
        @methods_require_internet.push(:daily, :weekly, :monthly, :mts)

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-n", "--name=NAME", "A name to pass to the script (not all commands support this flag)") do |name|
            @name = name
          end
        end.parse!

        super
      end

      # generate daily notes
      def daily
        title = @format.date_templates[NOTEBOOK_DAILY]
        body = @format.template_contents(NOTEBOOK_DAILY)
        body += to_enml($config.custom_sections[NOTEBOOK_DAILY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_DAILY

        @model.create_note(title: title, body: body, parent_notebook: parent_notebook)
      end

      # generate weekly notes
      def weekly
        title = @format.date_templates[NOTEBOOK_WEEKLY]
        body = @format.template_contents(NOTEBOOK_WEEKLY)
        body += to_enml($config.custom_sections[NOTEBOOK_WEEKLY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_WEEKLY

        note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        # BUG: inability to tag notes lies somewhere in evertils-common,
        # specifically in how note.tag works
        # As this is non-functional, lets not run it - commented out for now
        # tag_manager = Evertils::Common::Manager::Tag.instance
        # week_tag = tag_manager.find_or_create("week-#{Date.today.cweek}")
        # note.tag(week_tag.prop(:name))
      end

      # generate monthly notes
      def monthly
        title = @format.date_templates[NOTEBOOK_MONTHLY]
        body = @format.template_contents(NOTEBOOK_MONTHLY)
        body += to_enml($config.custom_sections[NOTEBOOK_MONTHLY]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_MONTHLY

        note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        # BUG: inability to tag notes lies somewhere in evertils-common,
        # specifically in how note.tag works
        # As this is non-functional, lets not run it - commented out for now
        # tag_manager = Evertils::Common::Manager::Tag.instance
        # month_tag = tag_manager.find_or_create("month-#{Date.today.month}")
        # note.tag(month_tag.prop(:name))
      end

      # generate monthly task summary templates
      def mts
        Notify.error("Name argument is required", {}) if @name.nil?

        title = "#{@name} #{DateTime.now.strftime('%m-%Y')}"
        body = @format.template_contents(NOTEBOOK_MTS)
        body += to_enml($config.custom_sections[NOTEBOOK_MTS]) unless $config.custom_sections.nil?
        parent_notebook = NOTEBOOK_MTS

        # create the note from template
        mts_note = @model.create_note(title: title, body: body, parent_notebook: parent_notebook)

        # BUG: inability to tag notes lies somewhere in evertils-common,
        # specifically in how note.tag works
        # As this is non-functional, lets not run it - commented out for now
        # tag_manager = Evertils::Common::Manager::Tag.instance
        # month_tag = tag_manager.find_or_create("month-#{Date.today.month}")
        # mts_note.tag(month_tag.prop(:name))

        # TODO: commented out until support for multiple tags is added
        # client_tag = tag_manager.find_or_create(@name)
        # mts_note.tag(client_tag.prop(:name))
      end

      # generate priority queue notes
      # TODO: delete method self.pq after this is tested/working
      def pq_dev
        note = nil

        if Date.today.monday?
          # get friday's note
          friday = (Date.today - 3)
          note_title = "Queue For [#{friday.strftime('%B %-d')} - F]"
          note = @model.find_note_contents(note_title)

          # @model.create_note(title: note.entity.title, body: note.entity.body, parent_notebook: NOTEBOOK_PRIORITY_QUEUE)
        elsif Date.today.tuesday? || Date.today.wednesday?
          # find monday's note
          monday = (Date.today - 1)
          monday_note_title = "Queue For [#{monday.strftime('%B %-d')} - M]"
          monday_note = @model.find_note_contents(monday_note_title)

          if !monday_note.entity.nil?
            note = monday_note.entity
          else
            # if it does not exist, get friday's note
            friday = (Date.today - 4)
            note_title = "Queue For [#{friday.strftime('%B %-d')} - F]"
            note = @model.find_note_contents(note_title)
          end

          # @model.create_note(title: note.entity.title, body: note.entity.body, parent_notebook: NOTEBOOK_PRIORITY_QUEUE)
        else
          title = @format.date_templates[NOTEBOOK_PRIORITY_QUEUE]
          body = @format.template_contents(NOTEBOOK_PRIORITY_QUEUE)
          body += to_enml($config.custom_sections[NOTEBOOK_PRIORITY_QUEUE]) unless $config.custom_sections.nil?

          # note = @model.create_note(title: title, body: body, parent_notebook: NOTEBOOK_PRIORITY_QUEUE)
        end

        # puts note.entity.inspect
        note
      end

      # generate priority queue notes
      def pq
        title = @format.date_templates[NOTEBOOK_PRIORITY_QUEUE]
        body = @format.template_contents(NOTEBOOK_PRIORITY_QUEUE)
        body += to_enml($config.custom_sections[NOTEBOOK_PRIORITY_QUEUE]) unless $config.custom_sections.nil?

        @model.create_note(title: title, body: body, parent_notebook: NOTEBOOK_PRIORITY_QUEUE)
      end

      # creates the notes required to start the day
      #  - priority queue
      #  - daily
      #  - weekly (if today is Monday)
      def morning
        pq
        daily
        weekly if Date.today.monday?
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

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
      def pq
        content, title = nil

        if Date.today.monday?
          title, content = pq_do_monday
        elsif Date.today.tuesday?
          title, content = pq_do_tuesday
        else
          title, content = pq_do_default
        end

        raise 'Invalid title' if title.nil?
        raise 'Invalid note content' if content.nil?

        @model.create_note(title: title, body: content, parent_notebook: NOTEBOOK_PRIORITY_QUEUE)
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

      #
      # @since 0.3.5
      def prepare_enml(content)
        # remove the xml declaration and DTD
        content = content.split("\n")
        content.shift(2)

        xml = Nokogiri::XML::DocumentFragment.parse(content.join)
        note_xml = xml.search('en-note')

        # remove <br> tags
        note_xml.search('br').each do |br|
          br.remove
        end

        enml = note_xml.inner_html().to_s

        # append custom sections to the end of the content if they exist
        return enml if $config.custom_sections.nil?

        enml += to_enml($config.custom_sections[NOTEBOOK_PRIORITY_QUEUE])
        enml
      end

      #
      # @since 0.3.7
      def pq_do_monday
        # get friday's note
        friday = (Date.today - 3)
        dow = @format.day_of_week(friday.strftime('%a'))
        note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(note_title)

        raise "Queue was not found - #{friday.strftime('%B %-d')}" unless found

        [
          @format.date_templates[NOTEBOOK_PRIORITY_QUEUE],
          prepare_enml(found.entity.content)
        ]
      end

      #
      # @since 0.3.7
      def pq_do_tuesday
        # find monday's note
        monday = (Date.today - 1)
        dow = @format.day_of_week(monday.strftime('%a'))
        monday_note_title = "Queue For [#{monday.strftime('%B %-d')} - #{dow}]"
        monday_note = @model.find_note_contents(monday_note_title)

        if !monday_note.entity.nil?
          note = monday_note.entity
          note.title = @format.date_templates[NOTEBOOK_PRIORITY_QUEUE]
        else
          # if it does not exist, get friday's note
          friday = (Date.today - 4)
          dow = @format.day_of_week(friday.strftime('%a'))
          note_title = "Queue For [#{friday.strftime('%B %-d')} - #{dow}]"
          note = @model.find_note_contents(note_title)
        end

        raise 'Queue was not found' unless note

        [
          note.title,
          prepare_enml(note.content)
        ]
      end

      #
      # @since 0.3.7
      def pq_do_default
        yest = (Date.today - 1)
        dow = @format.day_of_week(yest.strftime('%a'))
        yest_note_title = "Queue For [#{yest.strftime('%B %-d')} - #{dow}]"
        found = @model.find_note_contents(yest_note_title).entity

        raise "Queue was not found - #{yest.strftime('%B %-d')}" unless found

        [
          @format.date_templates[NOTEBOOK_PRIORITY_QUEUE],
          prepare_enml(found.content)
        ]
      end
    end
  end
end

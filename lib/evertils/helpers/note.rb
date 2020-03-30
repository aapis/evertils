module Evertils
  module Helper
    class Note
      include Singleton

      attr_reader :model

      # Create the Note object
      def initialize
        @model = Evertils::Common::Query::Simple.new
        @format = Formatting.new
        @user = @model.user_info[:user]
        @shard = @model.user_info[:shard]
      end

      #
      # @since 1.0.12
      def wait_for_with_grammar(grammar, iterations = Evertils::Base::MAX_SEARCH_SIZE)
        Notify.info("Searching with grammar #{grammar}")
        note = find_note_by_grammar(grammar.to_s)

        begin
          if note.entity.nil?
            (1..iterations).each do |iter|
              grammar.tags[:day] -= 1
              Notify.info(" (#{iter}) Looking for #{grammar}")
              note = find_note_by_grammar(grammar.to_s, true)

              break unless note.entity.nil? || iter == Evertils::Base::MAX_SEARCH_SIZE
            end
          end
        rescue Interrupt
          Notify.error('Cancelled wait')
        end

        note
      end

      # Wait for a note to exist
      def wait_for_by_notebook(notebook, iterations = Evertils::Base::MAX_SEARCH_SIZE)
        Notify.info("Waiting for #{notebook}...")
        note = find_note_by_notebook(notebook)

        begin
          # didn't find it the first time?  wait and try again
          if note.entity.nil?
            (1..iterations).each do |iter|
              Notify.info(" (#{iter}) Looking for #{notebook.downcase}")
              note = find_note_by_notebook(notebook, true)
              break unless note.entity.nil? || iter == Evertils::Base::MAX_SEARCH_SIZE
            end
          end
        rescue Interrupt
          Notify.error('Cancelled wait')
        end

        note
      end

      # Wait for a note to exist
      def wait_for_by_title(title, notebook, iterations = Evertils::Base::MAX_SEARCH_SIZE)
        Notify.info("Waiting for #{title}...")
        note = find_note_by_title(title)

        begin
          # didn't find it the first time?  wait and try again
          if note.entity.nil?
            (1..iterations).each do |iter|
              Notify.info(" (#{iter}) Looking for #{notebook.downcase}")
              note = find_note_by_title(notebook, true)
              break unless note.entity.nil? || iter == Evertils::Base::MAX_SEARCH_SIZE
            end
          end
        rescue Interrupt
          Notify.error('Cancelled wait')
        end

        note
      end

      # Find a note by note
      def find_note_by_title(title, sleep = false)
        sleep(5) if sleep
        @model.find_note_contents(title)
      end

      # Find a note by notebook
      def find_note_by_notebook(notebook, sleep = false)
        sleep(5) if sleep
        title = Formatting.date_templates[notebook]

        @model.find_note_contents(title)
      end
      # alias find_by_notebook

      def find_note_by_grammar(grammar, sleep = false)
        sleep(5) if sleep
        @model.find_note_contents_using_grammar(grammar)
      end

      #
      # @since 0.3.15
      def internal_url_for(note)
        "evernote:///view/#{@user[:id]}/#{@shard}/#{note.guid}/#{note.guid}/"
      end

      #
      # @since 1.0.0
      def external_url_for(note)
        "https://www.evernote.com/Home.action#n=#{note.guid}&s=#{@shard}&ses=4&sh=2&sds=5"
      end

      # Create a note
      def create(data)
        @model.create_note(data)
      end
      alias create_note create
    end
  end
end

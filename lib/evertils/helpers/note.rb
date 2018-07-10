module Evertils
  module Helper
    class Note
      attr_reader :model

      # Create the Note object
      def initialize
        @model = Evertils::Common::Query::Simple.new
        @format = Evertils::Helper.load('Formatting')
        @user = @model.user_info[:user]
        @shard = @model.user_info[:shard]
      end

      # Wait for a note to exist
      def wait_for(notebook)
        Notify.info("Waiting for #{notebook}...")
        note = find_note(notebook)

        begin
          # didn't find it the first time?  wait and try again
          if note.entity.nil?
            (1..Evertils::Type::Base::MAX_SEARCH_SIZE).each do |iter|
              Notify.info(" (#{iter}) #{notebook}")
              note = find_note(notebook, true)
              break unless note.entity.nil? || iter == Evertils::Type::Base::MAX_SEARCH_SIZE
            end
          end
        rescue Interrupt
          Notify.warning('Cancelled wait')
        end

        note
      end

      # Find a note
      def find_note(notebook, sleep = false)
        sleep(5) if sleep
        title = @format.date_templates[notebook]
        @model.find_note_contents(title)
      end
      alias find_by_notebook find_note

      #
      # @since 0.3.15
      def internal_url_for(note)
        "evernote:///view/#{@user[:id]}/#{@shard}/#{note.guid}/#{note.guid}/"
      end

      # Create a note
      def create(data)
        @model.create_note(data)
      end
      alias create_note create
    end
  end
end

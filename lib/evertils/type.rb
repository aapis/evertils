module Evertils
  module Type
    class Base
      attr_reader :title, :content, :notebook

      COLOUR = 0xffffff
      MAX_SEARCH_SIZE = 21

      #
      # @since 0.3.7
      def initialize(config, *args)
        @model = Evertils::Common::Query::Simple.new
        @user = @model.user_info[:user]
        @shard = @model.user_info[:shard]
        @format = Evertils::Helper.load('Formatting')
        @config = config if config
        @api = Evertils::Helper.load('ApiEnmlHandler', @config)
        @args = args unless args.size.zero?
      end

      #
      # @since 0.3.7
      def create
        data = {
          title: @title,
          body: @content.to_s.delete!("\n"),
          parent_notebook: self.class::NOTEBOOK,
          tags: tags || [],
          colour: self.class::COLOUR
        }

        raise 'Invalid title' if @title.nil?
        raise 'Invalid note content' if @content.nil?
        raise 'Invalid notebook' if self.class::NOTEBOOK.nil?

        @model.create_note(data)
      end

      #
      # @since 0.3.7
      def should_create?
        @note = find_note(self.class::NOTEBOOK)
        @entity = @note.entity
        result = @entity.nil?

        Notify.warning "#{self.class.name} skipped, note already exists" unless result

        result
      end

      #
      # @since 0.3.15
      def morning_note?
        !caller.grep(/morning/).nil?
      end

      #
      # @since 0.3.15
      def wait_for(notebook)
        Notify.info('Waiting for...')
        note = find_note(notebook)

        # didn't find it the first time?  wait and try again
        if note.entity.nil?
          (1..MAX_SEARCH_SIZE).each do |iter|
            Notify.info(" (#{iter}) #{notebook}")
            note = find_note(notebook, true)
            break unless note.entity.nil? || iter == MAX_SEARCH_SIZE
          end
        end

        note
      end

      #
      # @since 0.3.15
      def find_note(notebook, sleep = false)
        sleep(5) if sleep
        title = @format.date_templates[notebook]
        @model.find_note_contents(title)
      end

      #
      # @since 0.3.15
      def internal_url_for(note)
        "evernote:///view/#{@user[:id]}/#{@shard}/#{note.guid}/#{note.guid}/"
      end
    end
  end
end

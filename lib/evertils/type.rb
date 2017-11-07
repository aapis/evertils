module Evertils
  module Type
    class Base
      attr_reader :title, :content, :notebook

      COLOUR = 0xffffff

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
          body: @content.gsub!("\n", ''),
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
        note_title = @format.date_templates[self.class::NOTEBOOK]
        found = @model.find_note_contents(note_title)
        result = found.entity.nil?

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
        note = find_note(notebook)

        # didn't find it the first time?  wait and try again
        if note.entity.nil?
          iter = 0
          loop do
            iter += 1
            note = find_note(notebook, true)
            break unless note.entity.nil? || iter == 10
          end

          Notify.info("#{iter} attempts to find #{notebook} note") unless iter.zero?
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

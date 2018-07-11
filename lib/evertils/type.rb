module Evertils
  module Type
    class Base
      attr_reader :title, :content, :notebook

      COLOUR = 0xffffff
      MAX_SEARCH_SIZE = 11

      #
      # @since 0.3.7
      def initialize(config, *args)
        # helpers
        @note_helper = Evertils::Helper.load('Note')
        @format = Evertils::Helper.load('Formatting')

        @config = config
        @api = Evertils::Helper.load('ApiEnmlHandler', @config)
        @args = args unless args.size.zero?
      end

      #
      # @since 0.3.7
      def create
        data = {
          title: @title,
          body: @content.to_s.delete("\n"),
          parent_notebook: self.class::NOTEBOOK,
          tags: tags || [],
          colour: self.class::COLOUR
        }

        raise 'Invalid title' if @title.nil?
        raise 'Invalid note content' if @content.nil?
        raise 'Invalid notebook' if self.class::NOTEBOOK.nil?

        @note_helper.create_note(data)
      end

      #
      # @since 0.3.7
      def should_create?
        @note = @note_helper.find_note(self.class::NOTEBOOK)
        @entity = @note.entity
        result = @entity.nil?

        Notify.warning "#{self.class.name} skipped, note already exists" unless result

        result
      end

      #
      # @since 0.3.15
      def morning_note?
        !caller.grep(/morning/).empty?
      end
    end
  end
end

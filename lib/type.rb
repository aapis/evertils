module Evertils
  module Type
    class Base
      #
      # @since 0.3.7
      def initialize(*args)
        @model = Evertils::Common::Query::Simple.new
        @format = Evertils::Helper.load('Formatting')
        @args = args unless args.size.zero?
      end

      #
      # @since 0.3.7
      def create
        data = {
          title: @title,
          body: @content,
          parent_notebook: self.class::NOTEBOOK
        }

        raise 'Invalid title' if @title.nil?
        raise 'Invalid note content' if @content.nil?
        raise 'Invalid notebook' if self.class::NOTEBOOK.nil?

        @model.create_note(data)
      end

      #
      # @since 0.3.7
      def should_create?
        raise 'Should be overwritten in sub classes'
      end
    end
  end
end

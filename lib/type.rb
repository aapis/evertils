module Evertils
  module Type
    class Base
      #
      # @since 0.3.7
      def initialize(*args)
        @model = Evertils::Common::Query::Simple.new
        @format = Evertils::Helper.load('formatting')
        @args = args unless args.size.zero?
      end

      #
      # @since 0.3.7
      def create
        data = {
          title: @title,
          body: @content,
          parent_notebook: notebook
        }

        raise 'Invalid title' if @title.nil?
        raise 'Invalid note content' if @content.nil?
        raise 'Invalid notebook' if notebook.nil?

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
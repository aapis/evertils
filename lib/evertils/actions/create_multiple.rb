# frozen_string_literal: true

module Evertils
  module Action
    class CreateMultiple < Action::Base
      def initialize(args, controller)
        super(args)

        query = Evertils::Common::Query::Simple.new
        children.each do |child|
          # avoid infinite recursion
          next if ['create_multiple'].include?(child['action'])

          child['path'].gsub!('%SELF%', '~/.evertils/templates/type')

          # query.create_note_from_yml(File.expand_path(child['path']))
          template_contents = YAML.load_file(File.expand_path(child['path']))

          runner = ActionRunner.new
          runner.params = template_contents
          runner.execute
        end
      end

      private

      # def execute(action)
      #   case action
      #   when 'create'
      #     Action::Create.new(@allowed_fields)
      #   when 'duplicate_previous'
      #     Action::DuplicatePrevious.new(@allowed_fields)
      #   else
      #     raise 'Invalid action'
      #   end
      # end

      def children
        contents = YAML.load_file(@args[:path])
        contents['notes']
      end
    end
  end
end

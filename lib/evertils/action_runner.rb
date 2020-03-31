# frozen_string_literal: true

module Evertils
  class ActionRunner
    attr_accessor :params

    def execute
      case params.action
      when nil
        Notify.info 'Action not provided, creating new note...'
        Action::Create.new(params)
      when 'create'
        Action::Create.new(params)
      when 'create_multiple'
        Action::CreateMultiple.new(params.notes)
      when 'duplicate_previous'
        Action::DuplicatePrevious.new(params)
      else
        Action::Default.new(action: action)
      end
    end
  end
end

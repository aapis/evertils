# frozen_string_literal: true

module Evertils
  class ActionRunner
    attr_accessor :params

    def execute
      case params.action
      when 'create'
        Action::Create.new(params)
      when 'create_multiple'
        Action::CreateMultiple.new(params.notes)
      when 'duplicate_previous'
        Action::DuplicatePrevious.new(params)
      when 'search'
        Action::Search.new(params)
      when 'group'
        Action::Group.new(params)
      else
        Action::Default.new(action: action)
      end
    end
  end
end

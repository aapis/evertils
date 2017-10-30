require_relative '../types/priority-queue'
require_relative '../types/monthly-task-summary'
require_relative '../types/daily'
require_relative '../types/weekly'
require_relative '../types/monthly'

module Evertils
  module Controller
    class Generate < Controller::Base
      # generate daily notes
      def daily
        note = Type::Daily.new(@config)
        note.create
      end

      # generate weekly notes
      def weekly
        note = Type::Weekly.new(@config)
        note.create
      end

      # generate monthly notes
      def monthly
        note = Type::Monthly.new(@config)
        note.create
      end

      # generate monthly task summary templates
      def mts(arg)
        Notify.error('Name argument is required', {}) if arg.nil?

        note = Type::MonthlyTaskSummary.new(@config, arg[1])
        note.create
      end

      # generate priority queue notes
      def pq
        note = Type::PriorityQueue.new(@config)
        note.create
      end

      # creates the notes required to start the day
      #  - priority queue
      #  - daily
      #  - weekly (if today is Monday and there isn't a weekly log already)
      #  - monthly (if today is the 1st and there isn't a monthly log already)
      def morning
        pq = Type::PriorityQueue.new(@config)
        pq.create

        daily = Type::Daily.new(@config)
        daily.create

        weekly = Type::Weekly.new(@config)
        weekly.create if weekly.should_create?

        monthly = Type::Monthly.new(@config)
        monthly.create if monthly.should_create?
      end
    end
  end
end

require_relative '../types/priority-queue'
require_relative '../types/monthly-task-summary'
require_relative '../types/daily'
require_relative '../types/weekly'
require_relative '../types/monthly'

module Evertils
  module Controller
    class Generate < Controller::Base
      attr_accessor :name

      def pre_exec
        @methods_require_internet.push(:daily, :weekly, :monthly, :mts)

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} generate timeframe [...-flags]"

          opt.on("-n", "--name=NAME", "A name to pass to the script (not all commands support this flag)") do |name|
            @name = name
          end
        end.parse!

        super
      end

      # generate daily notes
      def daily
        note = Type::Daily.new
        note.create
      end

      # generate weekly notes
      def weekly
        note = Type::Weekly.new
        note.create
      end

      # generate monthly notes
      def monthly
        note = Type::Monthly.new
        note.create
      end

      # generate monthly task summary templates
      def mts
        Notify.error('Name argument is required', {}) if @name.nil?

        note = Type::MonthlyTaskSummary.new(@name)
        note.create
      end

      # generate priority queue notes
      def pq
        note = Type::PriorityQueue.new
        note.create
      end

      def test
        puts "yup"
      end

      # creates the notes required to start the day
      #  - priority queue
      #  - daily
      #  - weekly (if today is Monday and there isn't a weekly log already)
      #  - monthly (if today is the 1st and there isn't a monthly log already)
      def morning
        pq = Type::PriorityQueue.new
        pq.create

        daily = Type::Daily.new
        daily.create

        weekly = Type::Weekly.new
        weekly.create if weekly.should_create?

        monthly = Type::Monthly.new
        monthly.create if monthly.should_create?
      end
    end
  end
end

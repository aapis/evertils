module Granify
  module Model
    class Base
      attr_accessor :data, :branch, :browser, :command, :start

      def initialize(hash = nil)
        @data = hash || Granify::Model::Data.new

        # Current time
        #@time = @data.start
        # Time the command was executed
        @start = Time.now
        # Current working branch
        @branch = @data.branch
        # Browser to execute tests in
        @browser = @data.browser
        # Instantiate the command execution class
        @command = Command::Exec.new
      end

      def bind(hash)
        initialize(hash)
      end
    end
  end
end
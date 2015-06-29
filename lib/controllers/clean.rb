module Granify
  module Controller
    class Clean < Controller::Base
      # force clean logs
      def logs
        Logs.clean
      end
    end
  end
end
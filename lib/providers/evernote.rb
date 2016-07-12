module Evertils
  module Provider
    class Evernote < Provider::Base
      #
      # @since 0.4.0
      def model
        Evertils::Common::Query::Simple.new
      end
    end
  end
end
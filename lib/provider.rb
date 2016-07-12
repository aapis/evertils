module Evertils
  module Provider
    class Base
      #
      # @since 0.4.0
      def model
        raise "Providers must implement the 'model' method"
      end
    end
  end
end
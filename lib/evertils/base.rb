module Evertils
  class Base
    def initialize
      @format = Evertils::Helper.load('Formatting')
    end
  end
end
module Evertils
  class Base
    MAX_SEARCH_SIZE = 11

    def initialize
      @format = Evertils::Helper.load('Formatting')
    end
  end
end
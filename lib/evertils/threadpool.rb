module Evertils
  class ThreadPool
    #
    # @since 0.3.16
    def initialize
      @threads = []
    end

    #
    # @since 0.3.16
    def add(thread)
      @threads << thread
    end

    #
    # @since 0.3.16
    def join_all
      @threads.map(&:join)
    end
  end
end
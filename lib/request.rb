module Granify
  class Request
    attr_reader :controller, :command, :custom, :flags, :raw_flags

    def initialize
      @controller = nil
      @flags = ARGV.select { |f| f.start_with?('-') }.map { |f| f.split("=").map &:to_sym } || []
      @raw_flags = ARGV.select { |f| f.start_with?('-') } || []

      if ARGV.size > 0
        if !ARGV[0].start_with?('-')
          @controller = ARGV[0].to_sym rescue nil
        end
        
        @command = ARGV[1].to_sym rescue nil

        if ARGV.size > 2
          @custom = ARGV[2..ARGV.size].select { |p| !p.start_with?('-') }.map &:to_sym || []
        end
      end
    end
  end
end
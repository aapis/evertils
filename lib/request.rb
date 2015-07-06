module Granify
  class Request
    attr_reader :controller, :command, :custom, :flags, :raw_flags

    def initialize
      @controller = nil
      @flags = ARGV[0..ARGV.size].select { |f| f.start_with?('-') }.map { |f| f.split("=").map &:to_sym } || []

      if ARGV.size > 1
        @controller = ARGV[0].to_sym rescue nil
        @command = ARGV[1].to_sym rescue nil

        if ARGV.size > 2
          @custom = ARGV[2..ARGV.size].select { |p| !p.start_with?('-') }.map &:to_sym || []
          # TODO: parameterize flag key/values
          @flags = ARGV[2..ARGV.size].select { |f| f.start_with?('-') }.map { |f| f.split("=").map &:to_sym } || []
          @raw_flags = ARGV[2..ARGV.size].select { |f| f.start_with?('-') } || []
        end
      end
    end
  end
end
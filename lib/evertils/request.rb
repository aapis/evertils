module Evertils
  class Request
    # Access controller variable property externally
    attr_accessor :controller
    # Access command variable property externally
    attr_reader :command
    # Access custom variable property externally
    attr_reader :custom
    # Access flags variable property externally
    attr_reader :flags
    # Access raw_flags variable property externally
    attr_reader :raw_flags
    # Access param variable property externally
    attr_accessor :param

    # Create the request object, parse ARGV for values
    def initialize
      raise ArgumentError, "ARGV is empty" if ARGV.empty?

      @flags = ARGV.select { |f| f.start_with?('-') }.map { |f| f.split('=').map(&:to_sym) } || []
      @raw_flags = ARGV.select { |f| f.start_with?('-') } || []
      @controller = ARGV[0].to_sym unless ARGV[0].start_with?('-')
      @command = ARGV[1].to_sym unless ARGV[1].nil?

      return unless ARGV.size > 2

      @custom = ARGV[2..ARGV.size].reject { |p| p.start_with?('-') }.map(&:to_sym) || []
      @param = ARGV[2]
    end
  end
end

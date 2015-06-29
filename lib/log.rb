module Granify
  class Log
    attr_accessor :path, :total_files_processed
    attr_reader :template

    def initialize(*args)
      if args.length == 0
        # default log
        @template = "#{Granify::LOG_DIR}/%s"
        @path = sprintf(@template, "default.log")
      else
        @template = "#{Granify::LOG_DIR}/%s/%s-%s.log"
        
        format(args)
      end

      @path
    end

    def stale?
      Time.now - last_write > 60
    end

    def exists?
      File.exist? @path
    end

    def delete
      if exists?
        File.delete @path
      end

      Notify.sinfo("Deleting truncated log file #{@path}")
      @path = nil
    end

    def num_lines
      File.foreach(@path).inject(0) {|c, line| c+1}
    end

    def faults
      matchdata = { :errors => 0, :warnings => 0, :total => 0 }

      begin
        case @log_type
        when :js
          last_line = IO.readlines(@path)[-5].chomp
          matches = last_line.match(/(\d+) example, (\d+) failure/)
          
          if matches
            matchdata[:errors] += matches[2].to_i
          end
        when :coffeelint
          total = 0
          File.foreach(@path) do |line|
            matches = line.match(/Lint\! » (\d+) errors and (\d+)/)

            if matches
              matchdata[:errors] += matches[1].to_i
              matchdata[:warnings] += matches[2].to_i
            end
          end
        when :ruby
          last_line = IO.readlines(@path)[-1].chomp
          matches = last_line.match(/(\d+) files inspected\, (\d+)/)

          if matches
            matchdata[:errors] += matches[2].to_i
            matchdata[:total] += matches[1].to_i
          end
        when :goliath

        else
          raise ArgumentError, "Unknown log type - #{log_type}"
        end
      rescue => e
        Notify.error(e.message)
      end

      matchdata
    end

    def to_s
      @path
    end

    private
      def format(args)
        @identifier = args[2]

        @path = sprintf(@template,
          @identifier,
          args[0],
          args[1].strftime('%Y-%m-%d-%T')
          )

        if !File.exists? @path
          Utils.generate_path(args[0], args[1].strftime('%Y-%m-%d-%T'), @identifier)
        end

        # create the log file, populate it with temporary data
        File.open(@path, 'w+') do |f|
          f.write("Command output will be logged below when it finishes running\n")
        end
      end

      def last_write
        File.mtime(@path)
      end
  end
end
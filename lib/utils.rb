module Evertils
  class Utils
    @cache = Hash.new
    
    # Gets a list of files from the current directory with a specific extension
    def self.get_files(ext)
      @cache[:files] ||= Hash.new
      @cache[:files][ext] ||= []

      Dir["*.#{ext}"].each do |file|
        @cache[:files][ext].push file
      end

      @cache[:files][ext]
    end

    # Gets a list of all files in the project with a specific extension
    def self.get_all_files(ext, ignore_paths = '')
      @cache[:files] ||= Hash.new
      @cache[:files][ext] ||= []

      if @cache[:files][ext].empty?
        Dir["**/*.#{ext}"].each do |file|
          if !ignore_paths.empty?
            # file is a widget
            if /\/#{ignore_paths}/.match(file)
              @cache[:files][ext].push file
            end
          else
            # file is not a widget
            @cache[:files][ext].push file
          end
        end
      end

      @cache[:files][ext]
    end

    # Gets a list of files from the current git commit queue with a specific
    # extension
    def self.get_files_from_git(ext)
      @cache[:files] ||= Hash.new
      @cache[:files][ext] ||= []

      modified_files = `git status --porcelain`.split("\n")
      modified_files.each do |file|
        if file.match(/#{ext}/)
          @cache[:files][ext].push file.strip.match(/[A-Z ]+(.*)/)[1]
        end
      end
      
      @cache[:files][ext]
    end

    # Generate a filename
    def self.generate_path(branch, time, identifier)
      # create the directory if needed
      Logs.mkdir identifier

      # create a new log file with a path based on the input parameters
      #Log.new(identifier, branch, time)
    end

    # Convert hash keys to symbols
    def self.symbolize_keys(hash)
      Hash[hash.map{ |k, v| [k.to_sym, v] }]
    end

     # Create a directory wherever the script is called from, if required
    def self.mklocaldir(name)
      dir = "#{Dir.pwd}/#{name.downcase}/"

      if !Dir.exist? dir
        Dir.mkdir dir
      else
        dir
      end
    end

    def self.os
      begin
        @os ||= (
          host_os = RbConfig::CONFIG['host_os']
          case host_os
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
          when /darwin|mac os/
            :macosx
          when /linux/
            :linux
          when /solaris|bsd/
            :unix
          else
            raise TypeError, "unknown os: #{host_os.inspect}"
          end
        )
      rescue err
        Notify.error(err.message)
      end
    end

    def self.json?(string)
      begin
        !!JSON.parse(string)
      rescue
        false
      end
    end

    def self.http_response_code(url = nil)
      begin
        request = Net::HTTP.get_response(URI.parse(url || "http://google.com"))
        request.code.to_i
      rescue
        500
      end
    end

    def self.has_internet_connection?
      Utils.http_response_code < 499
    end

    def self.token
      conf = YAML::load_file(Evertils::USER_CONF)
      conf['token']
    end
  end
end

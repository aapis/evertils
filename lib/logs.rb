module Granify
  class Logs
    MAX_LOGS_TO_STORE = 30

    @files = Dir["#{Granify::LOG_DIR}/*/*.log"]

    def self.clean
      if @files.size > 0
        @files.each do |file|
          File.delete file if File.exist? file
        end
        Notify.info("Removed #{@files.size} old log files")
      end
    end

    def self.dirty?
      @files.size >= MAX_LOGS_TO_STORE
    end

    # Create a directory if required
    def self.mkdir(name)
      dir = "#{Granify::LOG_DIR}/#{name.downcase}"

      if !Dir.exist? dir
        Dir.mkdir dir
      end

      # Create the default .gitignore
      File.open("#{dir}/.gitignore", "w+") do |file|
        file.write "# Ignore everything in this directory\n*\n# Except this file\n!.gitignore"
      end
    end
  end
end
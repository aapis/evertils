module Granify
  module Command
    class Exec
      attr_reader :response, :exitcode
      attr_accessor :enable_logging

      #
      # class methods
      #
      class << self
        def git_queue_status
          if global("git log origin/#{git_current_branch}..HEAD --oneline")
            response = @response.split("\n")
            response.size > 0
          end
        end

        def git_push
          global("git push -q origin #{git_current_branch}")
        end

        def git_checkout
          begin
            curr_branch = git_current_branch
            branch = $request.custom.nil? ? curr_branch : $request.custom[0]

            if !git_branch_verify branch
              raise "Requested branch not found in the working copy: #{branch}"
            end

            if branch == curr_branch
              return Notify.warning("Requested branch is already checked out, skipping checkout")
            else
              global("git checkout -q #{branch}")
            end

            # not found locally, checkout from origin
            if !@response
              branch = "origin/#{branch}"
              global("git checkout -q #{branch}")
            end

            if !@response
              Notify.error("Unable to locate #{branch} on the remote server or local working copy")
            end

            branch
          rescue SystemExit, Interrupt
            Notify.error("Interrupt caught, exiting")
          rescue RuntimeError => e
            Notify.error(e.message)
          end
        end

        def git_current_branch
          global("git rev-parse --abbrev-ref HEAD")
        end

        def git_branch_verify(branch = nil)
          if branch.nil?
            branch = git_current_branch
          end

          global("git rev-parse --verify #{branch}")
        end

        def global(command, file = nil)
          begin
            # disable logging if user settings prohibit it
            #file = nil if !@enable_logging
            # default value for exit code is an error
            @exitcode = 1

            @response = `#{command}`.chomp
            @exitcode = $?.exitstatus

            # Log output to a file
            # This method is better than redirecting output to a file because now
            # the response is always populated instead of being empty when output
            # is sent to the log file
            if file
              File.open(file.path, 'w+') do |f|
                f.write(@response)
              end
            end

            @response
          rescue SystemExit, Interrupt
            Notify.error("Interrupt caught, exiting")
          end
        end
      end

      #
      # instance methods
      #
      def minify(file, destination)
        begin
          min_file = "#{destination}#{File.basename(file, File.extname(file))}.min.js"

          @response = `uglifyjs #{file} -cm -o "#{min_file}"`

          Notify.success("Minified #{file}")

          $?.exitstatus == 0
        rescue SystemExit, Interrupt
          Notify.error("Interrupt caught, exiting")
        end
      end

      def lint(file, log_file)
        begin
          command = `coffeelint -f "#{Granify::INSTALLED_DIR}/lib/configs/coffeelint.json" #{file}`

          @response = command.include?("Ok!")

          # only send errors to the log file
          if !@response
            File.open(log_file.path, 'a') do |f|
              f.write("Logged at #{Time.now}\n============================================================\n\n")
              f.write(command)
            end
          end

          $?.exitstatus == 0
        rescue SystemExit, Interrupt
          Notify.error("Interrupt caught, exiting")
        end
      end

      def open_editor(file=nil)
        begin
          log_file = file || Granify::DEFAULT_LOG

          # System editor is not set/unavailable, use system default to open the
          # file
          if `echo $EDITOR` == ""
            if Utils.os == :macosx
              `open #{log_file.path}`
            else
              `xdg-open #{log_file.path}`
            end
          else
            `$EDITOR #{log_file.path}`
          end
        rescue SystemExit, Interrupt
          Notify.error("Interrupt caught, exiting")
        end
      end

      def arbitrary(command, file = nil)
        begin
          # default value for exit code is an error
          @exitcode = 1
          @response = `#{command}`.chomp
          @exitcode = $?.exitstatus

          # Log output to a file
          # This method is better than redirecting output to a file because now
          # the response is always populated instead of being empty when output
          # is sent to the log file
          if file
            File.open(file.path, 'w+') do |f|
              f.write("Logged at #{Time.now}\n============================================================\n\n")
              f.write(@response)
            end
          end

          @exitcode == 0

          # support chaining
          self
        rescue SystemExit, Interrupt
          Notify.error("Interrupt caught, exiting")
        end
      end
    end
  end
end

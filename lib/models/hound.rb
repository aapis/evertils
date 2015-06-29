module Granify
  module Model
    class Hound < Model::Base
      def coffee_data(files = [])
        @data.identifier = :coffeelint

        if files.size > 0
          Notify.sinfo("Using command arguments as file list source")
        end

        # check if there are any files within the pwd
        if files.size == 0
          files = Utils.get_files(:coffee)
          
          if files.size > 0
            Notify.sinfo("Using #{Dir.pwd} as file list source")
          end
        end

        # check the current git queue for JS/Coffee files to lint
        if files.size == 0
          files = Utils.get_files_from_git(:coffee)
          
          if files.size > 0
            Notify.sinfo("Using current git-commit queue as file list source")
          end
        end

        # there were no files in the pwd, expand scope to all JS/Coffee files
        if files.size == 0
          files = Utils.get_all_files(:coffee)

          if files.size > 0
            Notify.sinfo("Using all .coffee files in current path (#{Dir.pwd}) as file list source")
          end
        end

        # update total file size
        @data.increment_status(:total, files.size)

        # no coffeescript files anywhere?? don't try to lint anything
        if files.size > 0
          files.each do |file|
            @command.lint(file, @data.log)

            if @command.response
              @data.status[:success] +=1
            else
              @data.status[:error] +=1
              @data.add_to_error_list(file)
            end
          end

          @data.log.total_files_processed = files.size
          
          validation_issues_in_coffee(@data.log)

          @data.success_rate[:int] = ((@data.status[:success].to_f / files.size.to_f) * 100).round(0)
          @data.success_rate[:str] = @data.success_rate[:int].to_s + "%"
          @data.status[:errors_per_file] = (@data.issues[:errors] / files.size.to_f).round(0)
          @data.below_acceptable_limit = @data.success_rate[:int] > 70 && @data.status[:errors_per_file] < 5
        else
          Notify.error("No coffeescript files to process, exiting")
          # don't need the current log file
          @data.log.delete
        end

        @data
      end

      def widgets_data(files = [])
        @data.identifier = :coffeelint

        if files.size > 0
          Notify.sinfo("Using command arguments as file list source")
        end

        # check if there are any files within the pwd
        if files.size == 0
          files = Utils.get_files(:coffee)
          
          if files.size > 0
            Notify.sinfo("Using #{Dir.pwd} as file list source")
          end
        end

        # check the current git queue for JS/Coffee files to lint
        if files.size == 0
          files = Utils.get_files_from_git(:coffee)
          
          if files.size > 0
            Notify.sinfo("Using current git-commit queue as file list source")
          end
        end

        # there were no files in the pwd, expand scope to all widget files
        if files.size == 0
          files = Utils.get_all_files(:coffee, 'widgets|widget_component')

          if files.size > 0
            Notify.sinfo("Using #{files.size} #{@data.identifier} files in (#{Dir.pwd}/widgets|widget_component) as file list source")
          end
        end

        # update total file size
        @data.increment_status(:total, files.size)

        # no coffeescript files anywhere?? don't try to lint anything
        if files.size > 0
          files.each do |file|
            @command.lint(file, @data.log)

            if @command.response
              @data.status[:success] +=1
            else
              @data.status[:error] +=1
              @data.add_to_error_list(file)
            end
          end

          @data.log.total_files_processed = files.size
          
          validation_issues_in_coffee(@data.log)

          @data.success_rate[:int] = ((@data.status[:success].to_f / files.size.to_f) * 100).round(0)
          @data.success_rate[:str] = @data.success_rate[:int].to_s + "%"
          @data.status[:errors_per_file] = (@data.issues[:errors] / files.size.to_f).round(0)
          @data.below_acceptable_limit = @data.success_rate[:int] > 70 && @data.status[:errors_per_file] < 5
        else
          Notify.error("No coffeescript files to process, exiting")
          # don't need the current log file
          @data.log.delete
        end

        @data
      end

      def ruby_data(files = [])
        @data.identifier = :ruby

        if files.size > 0
          Notify.sinfo("Using command arguments as file list source")
        end

        # check if there are any files within the pwd
        # COMMENTED OUT for now because this may not be required functionality
        # if files.size == 0
        #   files = Utils.get_files(:rb)

        #   if files.size > 0
        #     Notify.sinfo("Using #{Dir.pwd} as file list source")
        #   end
        # end

        # check the current git queue for JS/Coffee files to lint
        if files.size == 0
          files = Utils.get_files_from_git(:rb)

          if files.size > 0
            Notify.sinfo("Using current git-commit queue as file list source")
          end
        end

        # there were no files in the pwd, expand scope to all widget files
        if files.size == 0
          files = Utils.get_all_files(:rb)

          if files.size > 0
            Notify.sinfo("Using #{files.size} #{@data.identifier} files in (#{Dir.pwd}/widgets|widget_component) as file list source")
          end
        end
        
        if files.size > 0
          files.each do |file|
            @command.arbitrary("rubocop #{file}", @data.log)

            if @command.response
              @data.status[:success] +=1
            else
              @data.status[:error] +=1
              @data.add_to_error_list(file)
            end
          end
          
          @data.log.total_files_processed = @data.status[:total]

          validation_issues_in_ruby(@data.log)

          @data.status[:errors_per_file] = (@data.issues[:errors] / @data.status[:total]).round(0)
          @data.success_rate[:int] = @data.status[:errors_per_file]
          @data.success_rate[:str] = @data.success_rate[:int].to_s + "%"
          @data.below_acceptable_limit = @data.success_rate[:int] > 90 && @data.status[:errors_per_file] < 5
        else
          Notify.error("No coffeescript files to process, exiting")
          # don't need the current log file
          @data.log.delete
        end

        @data
      end

      private
        # TODO: can these be replaced by Log.errors
        def validation_issues_in_coffee(file)
          File.foreach(file.path) do |line|
            matches = line.match(/Lint\! » (\d+) errors and (\d+)/)
            
            if matches
              @data.increment_issues(:errors, matches[1].to_i)
              @data.increment_issues(:warnings, matches[2].to_i)
            end
          end

          @data.issues
        end

        # TODO: benchmark, this may be super slow
        def validation_issues_in_ruby(file)
          last_line = IO.readlines(file.path)[-1].chomp
          #matches = last_line.match(/(\d+) files inspected\, (\d+)/)
          matches = last_line.scan(/[0-9]+/)

          if matches
            @data.increment_issues(:errors, matches[1].to_i)
            @data.increment_status(:total, matches[0].to_i)
          end

          @data.issues
        end
    end
  end
end
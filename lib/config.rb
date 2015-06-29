module Granify
  class Cfg
    def bootstrap!
      begin
        # configure Notifaction gem
        Notify.configure do |c|
          c.plugins = []
        end

        # check for missing dependencies
        missing = []

        # test if we have all the required commands before sending anything to
        # handlers
        Granify::SHELL_COMMANDS[Utils.os].each do |command|
          Command::Exec.global("type \"#{command}\" > /dev/null 2>&1")

          if $?.exitstatus != 0
            missing.push("- "+ command)
          end
        end

        if !missing.empty?
          Notify.error("Required system commands and/or configuration variables are not installed:\n#{missing.join("\n")}")
        end

        if missing.size > 0
          # try to install the missing commands
          #Command::Exec.global("npm install --silent -g #{missing.join(' ')}")

          # commented out for now as it currently does nothing
          # if $?.exitstatus > 0
          #   # TODO: implement other auto-install commands such as apt-get
          # end
        end
      rescue => e
        Notify.error("#{e.to_s}\n#{e.backtrace.join("\n")}")
      end
    end
  end
end
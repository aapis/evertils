module Evertils
  class Router
    # Create the router object
    # Params:
    # +config_instance+:: An instance of Evertils::Cfg
    def initialize(config_instance)
      @config = config_instance
    end

    # Prepare for routing
    def pre_exec
      @request = Request.new

      begin
        # include the controller
        require "evertils/controllers/#{@request.controller}"
        # include helpers
        require "evertils/helpers/#{@request.controller}" if File.exist? "evertils/helpers/#{@request.controller}"

        update_config if uses_config_file?

        # perform all required checks
        must_pass = Helper::Results.new
        @config.get(:required).each do |key, _|
          must_pass.add(send("verify_#{key}"))
        end

        raise RequiredCheckException unless must_pass.should_eval_to(true)
      rescue YubikeyException
        Notify.error('Check failed: Yubikey is not inserted')
      rescue GpgException
        Notify.error('Check failed: GPG key not found or not imported into your keychain')
      rescue RequiredCheckException
        Notify.error('One or more required checks failed')
      rescue LoadError => e
        Notify.error(e || "Controller not found: #{@request.controller}")
      end
    end

    # Perform command routing
    def route
      pre_exec

      # Create object context and pass it the required command line arguments
      begin
        unless @request.controller.nil?
          controller = Evertils::Controller.const_get @request.controller.capitalize
          controller = Evertils::Controller::Render if @config.exist?(:path)

          # create an instance of the requested controller
          context = controller.new(@config, @request)

          if context.can_exec? @request.command, @config
            # Set things up
            context.pre_exec

            # Run the requested action
            context.exec

            # Run cleanup commands
            context.post_exec
          end
        end
      rescue NoMethodError => e
        Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
      rescue RuntimeError => e
        Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
      rescue NameError => e
        Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
      end
    end

    def uses_config_file?
      @config_file_path = File.expand_path("~/.evertils/templates/type/#{@request.command}.yml")
      File.exist? @config_file_path
    end

    def update_config
      additional_config = { path: @config_file_path }.merge(YAML.safe_load(File.read(@config_file_path)))
      @config.merge(additional_config).symbolize!
      overwrite_controller_with :render
    end

    def overwrite_controller_with(new_controller)
      @request.controller = new_controller
    end

    # checks output of gpg --list-keys for the presence of a specific GPG key
    def verify_gpgKey
      # TODO: replace with Open3
      res = system("gpg --list-keys  #{@config.get(:required, :gpgKey)} 2>/dev/null >/dev/null")

      raise GpgException unless res
      res
    end

    # checks output of ykman list to determine if the correct key is inserted
    def verify_yubikeySerial
      # TODO: replace with Open3
      res = system("ykman list | grep #{@config.get(:required, :yubikeySerial)} 2>/dev/null >/dev/null")

      raise YubikeyException unless res
      res
    end
  end
end

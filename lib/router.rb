module Evertils
  class Router
    def route
      # Populate request params
      $request = Request.new

      # include the controller
      if File.exists? "#{Evertils::CONTROLLER_DIR}#{$request.controller}.rb"
        require "#{Evertils::CONTROLLER_DIR}#{$request.controller}.rb"
      end

      # include helpers
      if File.exists? "#{Evertils::HELPER_DIR}#{$request.controller}.rb"
        require "#{Evertils::HELPER_DIR}#{$request.controller}.rb"
      end

      # include models
      if File.exists? "#{Evertils::MODEL_DIR}#{$request.controller}.rb"
        require "#{Evertils::MODEL_DIR}#{$request.controller}.rb"
      end

      # Create object context and pass it the required command line arguments
      begin
        if !$request.controller.nil?
          controller = Evertils::Controller.const_get $request.controller.capitalize rescue false
          
          if !controller
            raise "Controller not found: #{$request.controller.capitalize}"
          end

          context = controller.new

          if context.can_exec? $request.controller, $request.command
            context.pre_exec

            # no command sent?  Use default to populate model data
            model_method = ($request.command ? $request.command : context.default_method).to_s + "_data"

            # populate model data
            method = context.model.public_method(model_method) rescue false

            # model is not set, use Base model instead so the controller still has
            # access to model methods
            if context.model.nil?
              context.model = Model::Base.new
            end
            
            # If the method exists, set model data accordingly
            # If it doesn't exist then just fail silently, the model may not
            # be required by some controllers
            if method.respond_to? :call
              context.model.data = method.call($request.custom || [])
            end

            if context.methods_require_internet.include? $request.command
              if !Utils.has_internet_connection?
                raise RuntimeError, "Command `#{Evertils::PACKAGE_NAME} #{$request.controller} #{$request.command}` requires a connection to the internet.\nPlease check your network configuration settings."
              end
            end

            # Run the controller
            context.exec

            # Run cleanup commands
            context.post_exec
          end
        end
      rescue RuntimeError => e
        Notify.error("#{e.to_s}")
      rescue NameError => e
        Notify.error("#{e.to_s}\n#{e.backtrace.join("\n")}")
      end
    end
  end
end

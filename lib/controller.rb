module Evertils
  module Controller
    class Base
      attr_accessor :model, :helper, :methods_require_internet, :default_method

      @@options = Hash.new
      
      # Perform pre-run tasks
      def pre_exec
        # interface with the Evernote API so we can use it later
        @model = Evertils::Common::Queries::Simple.new

        @format = Evertils::Helper.load('formatting')

        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} controller command [...-flags]"

          opt.on("-v", "--verbose", "Verbose output") do |v|
            # short output
            @@options[:verbose] = v
          end

          opt.on("-V", "--version", "Show app version") do |v|
            # short output
            @version = Evertils::PACKAGE_VERSION
          end
        end.parse!
      end

      # Handle the request
      def exec(args = [])
        self.send(@default_method.to_sym)
      end

      # Perform post-run cleanup tasks, such as deleting old logs
      def post_exec(total_errors = 0, total_warnings = 0, total_files = 0)
        
      end

      # Determines if the command can execute
      def can_exec?(command = nil, name = nil)
        @model = Evertils::Model.const_get(command.capitalize).new rescue nil
        @helper = Evertils::Helper.const_get(command.capitalize).new rescue nil
        @methods_require_internet = []

        # get user-defined methods to use as a fallback
        user_defined_methods = []

        # timeout is the first system defined method after the user defined
        # ones
        for i in 0..public_methods.index(:to_json) -1
          user_defined_methods.push(public_methods[i].to_sym)
        end

        @default_method = name || user_defined_methods.first || :sample

        if !respond_to? default_method.to_sym, true
          Notify.error("Command not found: #{name}")
        end

        true
      end

      # default method called by exec if no argument is passed
      def sample
        Notify.warning("Method not implemented");
      end

      def required_modules(*modules)
        auto_load_required(modules).each do |type, hash|
          # Make each auto-loaded module available as an instance variable
          # i.e. [:hound]: @hound_controller, @hound_model, @hound_helper
          # i.e. [:test]: @test_controller, @test_model, @test_helper
          # Only files that exist and can be called are loaded
          hash.each do |key, value|
            instance_variable_set("@#{key}_#{type}".to_sym, value)
            @last_model = instance_variable_get("@#{key}_model")
          end
        end
      end

      private

      # autoload and instantiate required libraries, models and helpers
      def auto_load_required(modules = [])
        loaded = {:controller => {}, :helper => {}, :model => {}}
        
        begin
          modules.each do |mod|
            if File.exists? "#{Evertils::INSTALLED_DIR}/lib/controllers/#{mod}.rb"
              require "#{Evertils::INSTALLED_DIR}/lib/controllers/#{mod}.rb"
              
              loaded[:controller][mod] = Evertils::Controller.const_get(mod.capitalize).new
            else
              raise StandardError, "Controller not found: #{mod}"
            end

            if File.exists? "#{Evertils::INSTALLED_DIR}/lib/helpers/#{mod}.rb"
              require "#{Evertils::INSTALLED_DIR}/lib/helpers/#{mod}.rb"
              loaded[:helper][mod] = Evertils::Helper.const_get(mod.capitalize).new

              # auto-instantiate new instance of helper for the new instance of the controller
              loaded[:controller][mod].helper = loaded[:helper][mod]
            end

            if File.exists? "#{Evertils::INSTALLED_DIR}/lib/models/#{mod}.rb"
              require "#{Evertils::INSTALLED_DIR}/lib/models/#{mod}.rb"
              loaded[:model][mod] = Evertils::Model.const_get(mod.capitalize).new

              # auto-instantiate new instance of model for the new instance of the controller
              loaded[:controller][mod].model = loaded[:model][mod]
            else
              loaded[:controller][mod].model = Model::Base.new
            end
          end

          loaded
        rescue StandardError => e
          Notify.error(e.message)
        end
      end
    end
  end
end

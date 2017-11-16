module Evertils
  class Cfg
    # Perform first run tasks and create or read config file values
    def bootstrap!
      populate_config

      return if valid_config?

      # no config file found, lets create one using the firstrun controller
      require 'evertils/controllers/firstrun'

      config = {}
      request = {}

      controller = Evertils::Controller::Firstrun.new(config, request)
      controller.default

      populate_config
    end

    # Returns a hash of all module constants and their values
    def options
      keys = Evertils.constants.select { |name| constant?(name) }
      hash = {}

      keys.each { |key| hash[key] = Evertils.const_get(key) }
      hash
    end

    # Populates the internal hash which stores any values set in the config file
    def populate_config
      file = File.expand_path("~/.evertils/config.yml")
      fmt = Evertils::Helper.load('Formatting')

      begin
        @yml = fmt.symbolize(::YAML.load_file(file))
        self
      rescue
        @yml = nil
      end
    end

    # Get a specific value from the config file data
    # Params:
    # +name+:: String/symbol key value
    def get(name)
      @yml[name.to_sym]
    end

    private

    # Check if configuration data exists
    def valid_config?
      !@yml.nil?
    end

    # Checks if string is a constant
    def constant?(name)
      name == name.upcase
    end
  end
end
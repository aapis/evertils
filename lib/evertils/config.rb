# frozen_string_literal: true

module Evertils
  class Cfg
    REPLACEMENTS = {
      '%DOY%': Date.today.yday,
      '%MONTH_NAME%': Date.today.strftime('%B'),
      '%MONTH%': Date.today.month,
      '%DAY%': Date.today.day,
      '%DOW%': Date.today.wday,
      '%DOW_NAME%': Date.today.strftime('%a'),
      '%YEAR%': Date.today.year,
      '%WEEK%': Date.today.cweek,
      '%WEEK_START%': Date.commercial(Date.today.year, Date.today.cweek, 1),
      '%WEEK_END%': Date.commercial(Date.today.year, Date.today.cweek, 5)
    }

    # default values for initialization
    def initialize
      @yml = {}
    end

    # Perform first run tasks and create or read config file values
    def bootstrap!
      populate_config

      return if valid_config?

      # no config file found, lets create one using the firstrun controller
      require 'client/controller/firstrun'

      controller = Evertils::Controller::Firstrun.new
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
      @yml = Evertils::Helper::Formatting.symbolize_keys(::YAML.load_file(file))

      set_evertils_token

      self
    end

    # Get a specific value from the config file data
    # Params:
    # +name+:: String/symbol key value
    def get(name, child = nil)
      return @yml[name.to_sym][child.to_sym] unless child.nil?

      @yml[name.to_sym]
    end

    # Checks if a key exists
    # Params:
    # +name+:: String/symbol key value
    def exist?(name, child = nil)
      return @yml[name].key?(child.to_sym) unless child.nil?

      @yml.key?(name.to_sym)
    end

    # Merge a hash into config data
    # Params:
    # +hash+:: Any arbitrary hash
    def merge(hash)
      @yml.merge!(hash)
      self
    end

    def symbolize!
      @yml = @yml.inject({}) { |h, (k, v)| h[k.to_sym] = v; h }
    end

    def pluck(*args)
      @yml.select do |key, _|
        args.include? key
      end
    end

    def translate_placeholders
      title_format = @yml[:title].dup

      @yml.map do |item|
        break if item.last.is_a? Hash

        REPLACEMENTS.each_pair do |k, v|
          item.last.gsub!(k.to_s, v.to_s) if item.last.is_a? String
          item.last.map { |i| i.gsub!(k.to_s, v.to_s) } if item.last.is_a? Array
        end
      end

      @yml[:title_format] = title_format unless @yml.key? :title_format

      Evertils::Helper::Formatting.symbolize_keys(@yml)
      self
    end

    private

    def set_evertils_token
      ENV['EVERTILS_TOKEN'] = @yml[:token]
    end

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
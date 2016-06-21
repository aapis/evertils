module Evertils
  PACKAGE_NAME = "evertils"
  INSTALLED_DIR = Gem::Specification.find_by_name(Evertils::PACKAGE_NAME).gem_dir
  LOG_DIR = INSTALLED_DIR + "/logs"
  DEFAULT_LOG = Evertils::Log.new # no args means default log
  HELPER_DIR = INSTALLED_DIR + "/lib/helpers/"
  CONTROLLER_DIR = INSTALLED_DIR + "/lib/controllers/"
  MODEL_DIR = INSTALLED_DIR + "/lib/models/"
  TEMPLATE_DIR = INSTALLED_DIR + "/lib/configs/templates/"
  LOG_DIGEST_LENGTH = 20
  DEBUG = false

  class Cfg
    attr_accessor :custom_sections, :custom_templates

    def bootstrap!
      begin
        # configure Notifaction gem
        Notify.configure do |c|
          c.plugins = []
        end
      rescue => e
        Notify.error("#{e.to_s}\n#{e.backtrace.join("\n")}")
      end

      load_user_customizations
    end

    def constant?(name)
      name == name.upcase
    end

    def options
      keys = Evertils.constants.select do |name|
        constant? name
      end

      hash = {}
      keys.each do |key|
        hash[key] = Evertils.const_get(key)
      end
      hash
    end

    #
    # @since 0.3.1
    def load_user_customizations
      conf = recursive_symbolize_keys(YAML::load_file(Dir.home + '/.evertils/config.yml'))

      @custom_sections = conf[:sections] if conf[:sections]
      @custom_templates = conf[:templates] if conf[:templates]
    end

    #
    # @since 0.3.1
    def recursive_symbolize_keys(hash)
      hash.inject({}){|result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then recursive_symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      }
    end

  end
end

module Evertils
  PACKAGE_NAME = "evertils"
  INSTALLED_DIR = '/Users/prieber/Personal/evertils' #Gem::Specification.find_by_name(Evertils::PACKAGE_NAME).gem_dir
  LOG_DIR = INSTALLED_DIR + "/logs"
  HELPER_DIR = INSTALLED_DIR + "/lib/helpers/"
  CONTROLLER_DIR = INSTALLED_DIR + "/lib/controllers/"
  TEMPLATE_DIR = INSTALLED_DIR + "/lib/configs/templates/"
  LOG_DIGEST_LENGTH = 20
  DEBUG = false

  class Cfg
    attr_accessor :custom_sections, :custom_templates, :custom_path, :provider

    def bootstrap!
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
      conf_path = Dir.home + '/.evertils/'
      conf = recursive_symbolize_keys(YAML::load_file(conf_path + 'config.yml'))

      @custom_path = conf_path
      @custom_sections = conf[:sections] if conf[:sections]
      @custom_templates = conf[:templates] if conf[:templates]
      @provider = conf[:provider] if conf[:provider]
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

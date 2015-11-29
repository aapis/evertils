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
    def bootstrap!
      begin
        # configure Notifaction gem
        Notify.configure do |c|
          c.plugins = []
        end
      rescue => e
        Notify.error("#{e.to_s}\n#{e.backtrace.join("\n")}")
      end
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
  end
end

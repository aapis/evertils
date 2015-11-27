module Evertils
  PACKAGE_NAME = "evertils"
  INSTALLED_DIR = Gem::Specification.find_by_name(Evertils::PACKAGE_NAME).gem_dir
  LOG_DIR = INSTALLED_DIR + "/logs"
  DEFAULT_LOG = Log.new # no args means default log
  HELPER_DIR = INSTALLED_DIR + "/lib/helpers/"
  CONTROLLER_DIR = INSTALLED_DIR + "/lib/controllers/"
  MODEL_DIR = INSTALLED_DIR + "/lib/models/"
  TEMPLATE_DIR = INSTALLED_DIR + "/lib/configs/templates/"
  LOG_DIGEST_LENGTH = 20
  DEBUG = false
end

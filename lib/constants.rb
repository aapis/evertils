module Granify
  PACKAGE_NAME = "evertils"
  INSTALLED_DIR = File.dirname($0)
  LOG_DIR = INSTALLED_DIR + "/logs"
  DEFAULT_LOG = Log.new # no args means default log
  HELPER_DIR = INSTALLED_DIR + "/lib/helpers/"
  CONTROLLER_DIR = INSTALLED_DIR + "/lib/controllers/"
  MODEL_DIR = INSTALLED_DIR + "/lib/models/"
  TEMPLATE_DIR = INSTALLED_DIR + "/lib/configs/templates/"
  LOG_DIGEST_LENGTH = 20
  SHELL_COMMANDS = {
    :macosx => %w(git uglifyjs rubocop),
    :linux => %w(git uglifyjs rubocop)
  }
  DEBUG = false
end
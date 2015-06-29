#!/usr/bin/env ruby

require "date"
require "time"
require "json"
require "optparse"
require "rbconfig"
require "evernote-thrift"
require "net/http"
require "uri"
require "fileutils"
require "cgi"
require "notifaction"

# include required files
require_relative "lib/helpers/time.rb"
require_relative "lib/config.rb"
require_relative "lib/request.rb"
require_relative "lib/log.rb"
require_relative "lib/constants.rb"
require_relative "lib/utils.rb"
require_relative "lib/logs.rb"
require_relative "lib/command.rb"
require_relative "lib/model_data.rb"
require_relative "lib/controller.rb"
require_relative "lib/router.rb"
require_relative "lib/model.rb"
require_relative "lib/helper.rb"

# Modify configuration options here
$config = Granify::Cfg.new
# Bootstrap!
$config.bootstrap!

# Config file located, route the request
req = Granify::Router.new
req.route

require 'date'
require 'time'
require 'json'
require 'optparse'
require 'rbconfig'
require 'evernote-thrift'
require 'net/http'
require 'uri'
require 'fileutils'
require 'cgi'
require 'notifaction'
require 'digest/md5'
require 'mime/types'
require 'evertils/common'
require 'yaml'
require 'nokogiri'

# include required files
require 'evertils/kernel'
require 'evertils/version'
require 'evertils/type'
require 'evertils/helpers/time'
require 'evertils/helpers/results'
require 'evertils/helpers/api-enml-handler'
require 'evertils/config'
require 'evertils/request'
require 'evertils/utils'
require 'evertils/command'
require 'evertils/controller'
require 'evertils/router'
require 'evertils/helpers/formatting'
require 'evertils/helpers/evernote-enml'
require 'evertils/helper'

module Evertils
  # Flag to determine if module is running in test mode
  def self.test?
    false
  end
end

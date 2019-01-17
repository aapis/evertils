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
# require 'open3'

# include required files
require 'evertils/kernel'
require 'evertils/version'
require 'evertils/base'
require 'evertils/type'
require 'evertils/helpers/time'
require 'evertils/helpers/results'
require 'evertils/helpers/api-enml-handler'
require 'evertils/gpg_exception'
require 'evertils/yubikey_exception'
require 'evertils/required_check_exception'
require 'evertils/config'
require 'evertils/request'
require 'evertils/controller'
require 'evertils/router'
require 'evertils/helper'
require 'evertils/helpers/formatting'
require 'evertils/helpers/evernote-enml'
require 'evertils/helpers/note'
require 'evertils/helpers/xml'

module Evertils
  # Flag to determine if module is running in test mode
  def self.test?
    false
  end
end

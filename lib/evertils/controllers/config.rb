# frozen_string_literal: true

require 'yaml/store'
require 'fileutils'

module Evertils
  module Controller
    class Config < Controller::Base
      def pre_exec
        conf = contents_of('~/.evertils/config.yml')
        @token = conf['gist_token'] unless conf['gist_token'].nil?
        # if the requested gist doesn't exist, ignore it and generate a new one
        @token = nil unless Gist.gist_exists?(@token)

        Gist.login! unless has_auth_already?
      end

      def push
        options = {
          public: false
        }

        options.merge!(update: @token) unless @token.nil?

        resp = Gist.multi_gist(payload, options)
        @token = resp['id'] if resp.key?('id')

        Notify.success("Gist created/updated - #{resp['html_url']}") if store_token?
      end

      def pull
        # TODO: refactor this crap
        files = Gist.download(@token)

        FileUtils.mv(File.expand_path('~/.evertils'), File.expand_path('~/.evertils.old'))
        FileUtils.mkdir_p(File.expand_path('~/.evertils/templates/type'))

        dir = {}
        t_pfx = '~/.evertils/templates/type'
        c_pfx = '~/.evertils'
        root_files = ['config.yml', 'rolling.log']

        files.each_pair do |_, file|
          dir["#{t_pfx}/#{file['filename']}"] = file['content'] unless file['filename'] == 'config.yml'
          dir["#{c_pfx}/#{file['filename']}"] = file['content'] if root_files.include?(file['filename'])
        end

        dir.each_pair do |path, contents|
          File.open(File.expand_path(path), 'w') { |f| f.write(contents) }
        end
      end

      private

      def payload
        {
          'config.yml' => contents_of('~/.evertils/config.yml').to_yaml,
          'rolling.log' => File.read(File.expand_path('~/.evertils/rolling.log'))
        }.merge(types)
      end

      def contents_of(file)
        YAML.load_file(File.expand_path(file))
      end

      def types
        types = {}

        Dir[File.expand_path('~/.evertils/templates/type/*.yml')].each do |dir|
          types["templates/type/#{dir.split('/').last}"] = contents_of(dir).to_yaml
        end

        types
      end

      def gist_authenticate
        Gist.login!
      end

      def has_auth_already?
        File.exist?(File.expand_path('~/.gist'))
      end

      def store_token?
        store = YAML::Store.new(File.expand_path('~/.evertils/config.yml'))
        yaml = contents_of('~/.evertils/config.yml')

        store.transaction do
          yaml.each_pair { |key, value| store[key] = value }
          store['gist_token'] = @token
        end

        true
      end
    end
  end
end

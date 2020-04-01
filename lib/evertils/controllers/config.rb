# frozen_string_literal: true

require 'yaml/store'

module Evertils
  module Controller
    class Config < Controller::Base
      def pre_exec
        conf = contents_of('~/.evertils/config.yml')
        @token = conf['gist_token'] unless conf['gist_token'].nil?
        # if the requested gist doesn't exist, ignore it and generate a new one
        puts @token.inspect
        @token = nil unless gist_exists?
        puts gist_exists?
        puts @token.inspect
        exit

        Gist.login! unless has_auth_already?
      end

      def push
        options = {
          public: false
        }

        options.merge!(update: @token) unless @token.nil?

        resp = Gist.multi_gist(payload, options)
        @token = resp['id'] if resp.key?('id')

        Notify.success("Gist created/updated - #{resp['url']}") if store_token?
      end

      def pull

      end

      private

      def payload
        {
          'config.yml' => contents_of('~/.evertils/config.yml').to_yaml
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

      def gist_exists?
        # begin


          gists = with_captured_stdout { puts Gist.list_all_gists }
          # puts gists.inspect

          # puts gists.scan(@token).inspect

        # rescue
        #   false
        # end
      end

      #
      # Thanks https://stackoverflow.com/a/22777806/7044855
      # @since 2.3.0
      def with_captured_stdout
        original_stdout = $stdout  # capture previous value of $stdout
        $stdout = StringIO.new     # assign a string buffer to $stdout
        yield                      # perform the body of the user code
        $stdout.string             # return the contents of the string buffer
      ensure
        $stdout = original_stdout  # restore $stdout to its previous value
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

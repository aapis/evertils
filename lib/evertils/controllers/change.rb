module Evertils
  module Controller
    class Change < Controller::Base
      REQUIRED_TOKEN_GROUPS = [:S, :U, :E, :C, :P, :A, :V, :H].freeze
      CONFIG = File.expand_path('~/.evertils/config.yml')
      ERROR_MESSAGE = "Token invalid\nGet one from https://www.evernote.com/Login.action?targetUrl=%2Fapi%2FDeveloperToken.action".freeze

      # Change the defined Evernote token
      def token
        Notify.spit 'Already have your Evernote token? Paste it now:'

        begin
          set_evertils_token
        rescue RuntimeError
          Notify.error ERROR_MESSAGE
        rescue Interrupt
          Notify.error ERROR_MESSAGE
        end

        Notify.success('Token saved!')
      end

      private

      def set_evertils_token
        token = STDIN.gets.chomp
        conf = YAML.load_file(CONFIG)
        conf['token'] = token

        raise unless valid? token

        overwrite_config_with(conf)
      end

      def overwrite_config_with
        File.open(CONFIG, 'w') { |file| file.write(conf.to_yaml) }
      end

      def valid?(token)
        token_groups = token.split(':').map do |group|
          group.split('=').first.to_sym
        end

        token_groups == REQUIRED_TOKEN_GROUPS
      end
    end
  end
end

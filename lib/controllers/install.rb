module Evertils
  module Controller
    class Install < Controller::Base
      def default
        create_config_file

        conf = YAML::load_file(Evertils::USER_CONF)

        if conf['token'] == 'nil' || !conf['token']
          puts "Already have your Evernote token? Paste it now:"

          begin
            token = STDIN.gets.chomp

            if token
              conf['token'] = token

              File.open(Evertils::USER_CONF, 'w') { |file| file.write(conf.to_yaml) }
              Notify.success("Token saved!\nEvertils is now installed correctly")
            end
          rescue Interrupt
            Notify.error "\nEvernote account token required!  Get your token at:\nhttps://www.evernote.com/Login.action?targetUrl=%2Fapi%2FDeveloperToken.action"
          end
        else
          Notify.success("Evertils is installed correctly")
        end
      end

      def change_token

      end

      def create_config_file
        return if File.exists? USER_CONF

        File.open(Evertils::USER_CONF, 'w') do |f|
          f.write('token: nil')
        end
      end
    end
  end
end

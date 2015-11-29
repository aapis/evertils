module Evertils
  module Controller
    class Install < Controller::Base
      def default
        create_config_file

        conf = YAML::load_file(Evertils::USER_CONF)

        if conf['token'] == 'nil' || !conf['token']
          Notify.spit "Already have your Evernote token? Paste it now:"

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
        if !authenticated?
          Notify.error("Current token is not valid, unable to change it")
        end

        Notify.spit "Paste your new Evernote token now:"

        begin
            conf = YAML::load_file(Evertils::USER_CONF)
            token = STDIN.gets.chomp

            if token
              conf['token'] = token

              File.open(Evertils::USER_CONF, 'w') { |file| file.write(conf.to_yaml) }
              Notify.success("Token saved!")
            end
          rescue Interrupt
            Notify.error "Cancelled"
          end
      end

      def authenticated?
        lib = Evertils::Helper.load('evernote')
        lib.authenticated?
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

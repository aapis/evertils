module Evertils
  module Controller
    class Firstrun < Controller::Base
      # Create the configuration file if it does not exist
      def default
        if File.exist?("#{Dir.home}/.evertils/config.yml")
          return Notify.warning('Configuration already exists, this is not the first run!')
        end

        FileUtils.mkdir_p("#{Dir.home}/.evertils/")

        File.open("#{Dir.home}/.evertils/config.yml", "w") do |f|
          f.write <<-'CONTENTS'
  templates:
  Monthly:
      "templates/monthly.enml"
  Daily:
      "templates/daily.enml"

  provider: Evernote
          CONTENTS
        end
      end
    end
  end
end

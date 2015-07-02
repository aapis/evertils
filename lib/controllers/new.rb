module Granify
  module Controller
    class New < Controller::Base
      attr_accessor :title, :file, :notebook

      def pre_exec
        begin
          # interface with the Evernote API so we can use it later
          @model = Granify::Helper.load('evernote')

          # all methods require internet to make API calls
          @methods_require_internet.push(:daily, :weekly, :monthly)

          # command flag parser
          OptionParser.new do |opt|
            opt.banner = "#{Granify::PACKAGE_NAME} new note [...-flags]"

            opt.on("-t", "--title=TITLE", "Set a custom title") do |title|
              @title = title
            end

            opt.on("-f", "--file=PATH", "Attach a file to your custom note") do |file|
              @file = file
            end

            opt.on("-n", "--notebook=PBOOK", "Attach a file to your custom note") do |notebook|
              @notebook = notebook
            end
          end.parse!

          # user = @model.get_user
          # Notify.success("Welcome, #{user.name} (#{user.username})")
        rescue ::Evernote::EDAM::Error::EDAMSystemException => e
          Notify.error("Evernote.authenticate error\n#{e.message} (#{e.errorCode})")
        rescue ::Evernote::EDAM::Error::EDAMUserException => e
          Notify.error("Evernote.authenticate error\n#{e.parameter} (#{e.errorCode})")
        end

        super
      end

      # Create a new Evernote note from data or terminal output
      def note
        message = JSON.parse(STDIN.gets).join || $request.custom
        message = message.gsub!("\n", '<br />')
        note = @model.create_note(@title || "Evertils - Custom Note", message, @notebook, @file)

        if note[:share_url]
          Notify.success("Note created and shared:\n#{note[:share_url]}")
        else
          Notify.error("Something dreadful happened!")
        end
      end

      # Create a new note and automatically share it
      def share_note
        message = JSON.parse(STDIN.gets).join || $request.custom
        message = message.gsub!("\n", '<br />')
        note = @model.create_note(@title || "Evertils - Custom Note", message, @notebook, @file, true)

        if note[:share_url]
          Notify.success("Note created and shared:\n#{note[:share_url]}")
        else
          Notify.error("Something dreadful happened!")
        end
      end
    end
  end
end
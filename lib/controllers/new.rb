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

          @title = "Evertils - Custom Note"

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

            opt.on("-b", "--body=BODY", "Note body") do |body|
              @body = body
            end
          end.parse!

          # user = @model.user
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
        if @body.nil?
          message = JSON.parse(STDIN.gets).join
          message = message.gsub!("\n", '<br />')
        else
          message = @body
        end

        note = @model.create_note(@title, message, @notebook, @file)

        if note[:note]
          Notify.success("Note created")
        else
          Notify.error("Unable to create note, are you authenticated?")
        end
      end

      # Create a new note and automatically share it
      def share_note
        if @body.nil?
          message = JSON.parse(STDIN.gets).join
          message = message.gsub!("\n", '<br />')
        else
          message = @body
        end

        # Prefix title to indicate it's shared status
        @title = "[SHARED] #{@title}"
        
        note = @model.create_note(@title, message, @notebook, @file, true)

        if note[:share_url]
          Notify.success("Note created and shared:\n#{note[:share_url]}")
        else
          Notify.error("Something dreadful happened!")
        end
      end
    end
  end
end
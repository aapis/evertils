module Granify
  module Controller
    class Convert < Controller::Base
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

            opt.on("-m", "--to-markdown", "Convert to MD format") do |b|
              @markdown = b
            end

            opt.on("-e", "--to-enml", "Convert to ENML") do |b|
              @file = b
            end

            opt.on("-n", "--notebook=PBOOK", "Attach a file to your custom note") do |notebook|
              @notebook = notebook.capitalize
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

      def notes_in
        unless @notebook
          Notify.error("Notebook (--notebook=) is a required argument")
        end

        metadata = @model.notes_by_notebook(@notebook)

        if metadata.is_a? Hash
          Notify.info("#{metadata.size} notes in #{@notebook}")
          Notify.info("Printing list of notes")

          metadata.each_pair do |note_guid, note_content|
            puts note_content
          end
        else
          Notify.error("Could not pull data for notebook #{@notebook}")
        end
      end
    end
  end
end
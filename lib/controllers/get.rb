module Granify
  module Controller
    class Get < Controller::Base
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

      # Get data about a notebook, prints titles of each child note
      def notebook
        if !$request.custom.nil?
          book = $request.custom[0]
          metadata = @model.get_notes_by_notebook(book)

          if metadata.is_a? ::Evernote::EDAM::NoteStore::NotesMetadataList
            Notify.info("#{metadata.totalNotes} notes in #{book}")
            Notify.info("Printing list of notes")

            metadata.notes.each do |note|
              puts note.title
            end
          else
            Notify.error("Could not pull data for notebook #{$request.custom[0]}")
          end
        else
          Notify.error("Notebook name is a required argument, i.e.\n#{Granify::PACKAGE_NAME} get notebook agendas")
        end
      end
    end
  end
end
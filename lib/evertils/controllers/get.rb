module Evertils
  module Controller
    class Get < Controller::Base
      attr_accessor :title, :file, :notebook

      def pre_exec
        # command flag parser
        OptionParser.new do |opt|
          opt.banner = "evertils new note [...-flags]"

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

        super
      end

      # Get data about a notebook, prints titles of each child note
      def notebook
        if !$request.custom.nil?
          book = $request.custom[0]
          metadata = @model.notes_by_notebook(book)

          if metadata.is_a? ::Evernote::EDAM::NoteStore::NotesMetadataList
            Notify.info("#{metadata.totalNotes} notes in #{book}")
            Notify.info("Printing list of notes")

            metadata.notes.each do |note|
              Notify.spit note.title
            end
          else
            Notify.error("Could not pull data for notebook #{$request.custom[0]}", {})
          end
        else
          Notify.error("Notebook name is a required argument, i.e.\n#{Evertils::PACKAGE_NAME} get notebook agendas", {})
        end
      end

      def info
        @config.options.each_pair do |key, value|
          Notify.spit("#{key}: #{value}")
        end
      end
    end
  end
end

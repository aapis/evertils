module Evertils
  module Controller
    class Convert < Controller::Base
      attr_accessor :title, :file, :notebook

      def pre_exec
        # command flag parser
        OptionParser.new do |opt|
          opt.banner = "#{Evertils::PACKAGE_NAME} new note [...-flags]"

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
            # convert it here!
            Notify.spit(note_content)
          end
        else
          Notify.error("Could not pull data for notebook #{@notebook}")
        end
      end
    end
  end
end

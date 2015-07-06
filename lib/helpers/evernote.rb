module Granify
  module Helper
    class Evernote
      @@developer_token = ENV["EVERTILS_TOKEN"]

      def initialize
        authenticate
      end

      def authenticate
        if @@developer_token.nil?
          Notify.error("Evernote developer token is not configured properly!\n$EVERTILS_TOKEN == nil")
        end

        @evernoteHost = "www.evernote.com"
        userStoreUrl = "https://#{@evernoteHost}/edam/user"

        userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
        userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
        @@user = ::Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)
        @@shardId = user.shardId

        versionOK = @@user.checkVersion("evernote-data",
                   ::Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
                   ::Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)

        @version = "#{::Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR}.#{::Evernote::EDAM::UserStore::EDAM_VERSION_MINOR}"

        if !versionOK
          Notify.error("Evernote API requires an update.  Latest version is #{@version}")
        end

        noteStoreUrl = @@user.getNoteStoreUrl(@@developer_token)

        noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
        noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
        @@store = ::Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
      end

      def info
        {
          :user => "#{user.name} (#{user.username}) - ID##{user.id}",
          :shard => user.shardId,
          :api_version => @version,
        }
      end

      def notebooks
        @@store.listNotebooks(@@developer_token)
      end

      def tags
        @@store.listTags(@@developer_token)
      end

      def user
        @@user.getUser(@@developer_token)
      end

      def notebook_by_name(name = $request.command)
        output = {}
        notebooks.each do |notebook|
          if notebook.name == name.to_s.capitalize
            output = notebook
          end
        end
        
        output
      end

      def notes_by_notebook(name)
        output = {}
        notebooks.each do |notebook|
          if notebook.name.to_s == name.capitalize.to_s
            filter = ::Evernote::EDAM::NoteStore::NoteFilter.new
            filter.notebookGuid = notebook.guid

            result = ::Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
            result.includeTitle = true
            result.includeUpdated = true
            result.includeTagGuids = true

            #output = @@store.findNotesMetadata(@@developer_token, filter, 0, 400, result)
            notes(nil, notebook.guid).notes.each do |note|
              output[note.guid] = @@store.getNoteContent(@@developer_token, note.guid)
            end
          end
        end

        output
      end

      def notebooks_by_stack(stack)
        output = {}
        notebooks.each do |notebook|
          if notebook.stack == stack
            #output[notebook.name] = []

            filter = ::Evernote::EDAM::NoteStore::NoteFilter.new
            filter.notebookGuid = notebook.guid

            result = ::Evernote::EDAM::NoteStore::NotesMetadataResultSpec.new
            result.includeTitle = true
            result.includeUpdated = true
            result.includeTagGuids = true

            notes = @@store.findNotesMetadata(@@developer_token, filter, 0, 400, result)
            output[notebook.name] = notes
          end
        end
        
        output
      end

      def note(title_filter = nil, notebook_filter = nil)
        filter = ::Evernote::EDAM::NoteStore::NoteFilter.new
        filter.words = "intitle:#{title_filter}" if title_filter
        filter.notebookGuid = notebook_filter if notebook_filter

        @@store.findNotes(@@developer_token, filter, nil, 1)
      end

      def notes(title_filter = nil, notebook_filter = nil)
        filter = ::Evernote::EDAM::NoteStore::NoteFilter.new
        filter.words = "intitle:#{title_filter}" if title_filter
        filter.notebookGuid = notebook_filter if notebook_filter

        @@store.findNotes(@@developer_token, filter, nil, 300)
      end

      def note_exists
        note = note(date_templates[$request.command])
        note.totalNotes > 0
      end

      def create_note(title = date_templates[$request.command], body = template_contents, p_notebook_name = nil, file = nil, share_note = false)
        if $request.command == :weekly && !Date.today.monday?
          Notify.error("Sorry, you can only create new weekly logs on Mondays")
        end

        # Create note object
        our_note = ::Evernote::EDAM::Type::Note.new
        our_note.resources = []
        our_note.tagNames = []

        # only join when required
        if body.is_a? Array
          body = body.join
        end

        # a file was requested, lets prepare it for storage
        if !file.nil?
          media_resource = EvernoteENML.new(file)
          body.concat(media_resource.embeddable_element)
          our_note.resources << media_resource.element
        end

        n_body = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
        n_body += "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
        n_body += "<en-note>#{body}</en-note>"
       
        # setup note properties
        our_note.title = title
        our_note.content = n_body

        # properly tag logs
        case $request.command
        when :weekly
          our_note.tagNames << "week-#{::Time.now.strftime('%V').to_i}"
        when :monthly
          our_note.tagNames << "month-#{::Time.now.strftime('%-m').to_i}"
        end

        if p_notebook_name.nil?
          parent_notebook = notebook_by_name
        else
          parent_notebook = notebook_by_name(p_notebook_name)
        end
        
        ## parent_notebook is optional; if omitted, default notebook is used
        if parent_notebook.is_a? ::Evernote::EDAM::Type::Notebook
          our_note.notebookGuid = parent_notebook.guid
        end

        ## Attempt to create note in Evernote account
        begin
          output = {}
          output[:note] = @@store.createNote(@@developer_token, our_note)
          
          if share_note
            shareKey = @@store.shareNote(@@developer_token, output[:note].guid)
            output[:share_url] = "https://#{@evernoteHost}/shard/#{@@shardId}/sh/#{output[:note].guid}/#{shareKey}"
          end
        rescue ::Evernote::EDAM::Error::EDAMUserException => edue
          ## Something was wrong with the note data
          ## See EDAMErrorCode enumeration for error code explanation
          ## http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
          Notify.error "EDAMUserException: #{edue}"
        rescue ::Evernote::EDAM::Error::EDAMNotFoundException => ednfe
          ## Parent Notebook GUID doesn't correspond to an actual notebook
          Notify.error "EDAMNotFoundException: Invalid parent notebook GUID"
        end

        # A parent notebook object exists, otherwise it was saved to the default
        # notebook
        if parent_notebook.is_a? ::Evernote::EDAM::Type::Notebook
          Notify.success("#{parent_notebook.stack}/#{parent_notebook.name}/#{our_note.title} created")
        else
          Notify.success("DEFAULT_NOTEBOOK/#{our_note.title} created")
        end

        output
      end

      def generate_stats
        {
          "Statistic description" => 9845.3894
        }
      end

      private
        # Legacy notes will have single/double character denotations for day of
        # week, this maps them.
        def day_of_week
          case Date.today.strftime('%a')
          when 'Mon'
            :M
          when 'Tue'
            :Tu
          when 'Wed'
            :W
          when 'Thu'
            :Th
          when 'Fri'
            :F
          end
        end

        def template_contents
          if Date.today.friday? && $request.command == :daily
            # Friday uses a slightly different template
            IO.readlines("#{Granify::TEMPLATE_DIR}#{$request.command}-friday.enml").join("").gsub!("\n", '')
          else
            IO.readlines("#{Granify::TEMPLATE_DIR}#{$request.command}.enml").join("").gsub!("\n", '')
          end
        end

        def date_templates
          now = DateTime.now
          end_of_week = now + 4 # days
          
          {
            :daily => "Daily Log [#{now.strftime('%B %-d')} - #{day_of_week}]",
            :weekly => "Weekly Log [#{now.strftime('%B %-d')} - #{end_of_week.strftime('%B %-d')}]",
            :monthly => "Monthly Log [#{now.strftime('%B %Y')}]"
          }
        end
    end
  end
  end
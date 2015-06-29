module Granify
  module Controller
    class New < Controller::Base
      def pre_exec
        begin
          # interface with the Evernote API so we can use it later
          @model = Granify::Helper::Evernote.new

          # all methods require internet to make API calls
          @methods_require_internet.push(:daily, :weekly, :monthly)

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
        if @model.note_exists
          Notify.error("There's already a log for today!")
        end

        @model.create_note("Custom Note", $request.custom, "Quarterly")
      end
    end
  end
end
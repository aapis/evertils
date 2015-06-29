module Granify
  module Controller
    class Generate < Controller::Base
      def pre_exec
        begin
          # interface with the Evernote API so we can use it later
          @model.authenticate

          # user = @model.get_user
          # Notify.success("Welcome, #{user.name} (#{user.username})")
        rescue ::Evernote::EDAM::Error::EDAMSystemException => e
          Notify.error("Evernote.authenticate error\n#{e.message} (#{e.errorCode})")
        rescue ::Evernote::EDAM::Error::EDAMUserException => e
          Notify.error("Evernote.authenticate error\n#{e.parameter} (#{e.errorCode})")
        end
      end

      # generate daily notes
      def daily
        if current_log_exists
          Notify.error("There's already a log for today!")
        end

        @model.create_note
      end

      # generate weekly notes
      def weekly
        if current_log_exists
          Notify.error("There's already a log for this week!")
        end
      end

      # generate monthly notes
      def monthly
        if current_log_exists
          Notify.error("There's already a log for this month!")
        end
      end

      private
        def current_log_exists
          @model.get_log
        end
    end
  end
end
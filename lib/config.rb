module Granify
  class Cfg
    def bootstrap!
      begin
        # configure Notifaction gem
        Notify.configure do |c|
          c.plugins = []
        end
      rescue => e
        Notify.error("#{e.to_s}\n#{e.backtrace.join("\n")}")
      end
    end
  end
end
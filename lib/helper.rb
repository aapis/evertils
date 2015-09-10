module Granify
  module Helper
    def self.load(klass, args = nil)
      begin
        klass_instance = Granify::Helper.const_get(klass.capitalize)
        
        if klass_instance
          if args.nil?
            klass_instance.new
          else
            klass_instance.new(args)
          end
        end
      rescue ::Evernote::EDAM::Error::EDAMSystemException => e
        Notify.error("Evernote.system error\n#{e.inspect.to_s}")
      rescue => e
        Notify.error(e.message)
      end
    end
  end
end
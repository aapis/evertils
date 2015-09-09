module Granify
  module StatsProcessor
    def self.load(klass, args = nil)
      begin
        klass_instance = Granify::StatsProcessor.const_get(klass.capitalize)
        
        if klass_instance
          if args.nil?
            klass_instance.new
          else
            klass_instance.new(args)
          end
        end
      rescue => e
        Notify.error(e.message)
      end
    end
  end
end
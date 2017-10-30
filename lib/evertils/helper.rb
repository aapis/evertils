module Evertils
  module Helper
    def self.load(klass, *args)
      begin
        klass_instance = Evertils::Helper.const_get(klass)

        if klass_instance
          if args.empty?
            klass_instance.new
          else
            klass_instance.new(args)
          end
        end
      rescue => e
        Notify.error("#{e}\n#{e.backtrace.join("\n")}", show_time: false)
      end
    end
  end
end

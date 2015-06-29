module Granify
  module Helper
    class Generate < Helper::Base
      def self.format_date(title)
        if title =~ /Daily/
          resp = /Daily Log \[([A-Z].*) \- [A-Z]\]/.match(title)

          if resp
            Time.parse($1)
          end
        elsif title =~ /Weekly/
          resp = /Weekly Log \[([A-Z].*) (\d+) \- (\d+)\]/.match(title)
          
          if resp
            first = Time.parse($1 +" "+ $2)
            second = Time.parse($1 +" "+ $3)

            [first, second]
          end
        elsif title =~ /Monthly/
          resp = /Monthly Log \[([A-Z].*) (\d+)\]/.match(title)

          if resp
            Time.parse($1 +" "+ $2)
          end
        elsif title =~ /Quarterly/
          resp = /Quarterly Log \[([A-Z].*) \- ([A-Z].*) (\d+)\]/.match(title)

          if resp
            first = Time.parse($1 +" "+ $3)
            second = Time.parse($2 +" "+ $3)

            [first, second]
          end
        end
      end
    end
  end
end
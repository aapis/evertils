module Evertils
  class Utils

    # Convert hash keys to symbols
    def self.symbolize_keys(hash)
      Hash[hash.map{ |k, v| [k.to_sym, v] }]
    end

    # Determine current OS
    def self.os
      begin
        @os ||= (
          host_os = RbConfig::CONFIG['host_os']
          case host_os
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            :windows
          when /darwin|mac os/
            :macosx
          when /linux/
            :linux
          when /solaris|bsd/
            :unix
          else
            raise TypeError, "unknown os: #{host_os.inspect}"
          end
        )
      rescue err
        Notify.error(err.message)
      end
    end

    def self.json?(string)
      begin
        !!JSON.parse(string)
      rescue
        false
      end
    end

    def self.http_response_code(url = nil)
      begin
        request = Net::HTTP.get_response(URI.parse(url || "http://google.com"))
        request.code.to_i
      rescue
        500
      end
    end

    def self.has_internet_connection?
      Utils.http_response_code < 499
    end
  end
end

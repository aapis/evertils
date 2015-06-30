module Granify
  module Helper
    class EvernoteENML
      attr_reader :element, :embeddable_element

      def initialize(type)
        send(type)
      end

      def plaintext
        file_path = $request.flags[0][1].to_s
        read_file = File.open(file_path, 'rb') { |io| io.read }

        @element = ::Evernote::EDAM::Type::Resource.new()
        @element.mime = 'text/plain'
        @element.data = ::Evernote::EDAM::Type::Data.new()
        @element.data.size = read_file.size
        @element.data.bodyHash = Digest::MD5.hexdigest(read_file)
        @element.data.body = read_file
        @element.attributes = ::Evernote::EDAM::Type::ResourceAttributes.new()
        @element.attributes.fileName = file_path # temporary for now, the actual file name

        @embeddable_element = "<br />Attachment with hash #{@element.data.bodyHash}<br /> <en-media type=\"#{@element.mime}\" hash=\"#{@element.data.bodyHash}\" /><br />"
      end
    end
  end
end
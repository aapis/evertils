module Evertils
  module Helper
    class EvernoteENML
      attr_reader :element, :embeddable_element

      def initialize(file = nil)
        @file = file
        @element = enml_element

        if !@element.nil?
          @embeddable_element = "<hr/>Attachment with hash #{@element.data.bodyHash}<br /><en-media type=\"#{@element.mime}\" hash=\"#{@element.data.bodyHash}\" /><br /><br />"
        end
      end

      private
        def enml_element
          if @file
            read_file = File.open(@file, 'rb') { |io| io.read }

            el = ::Evernote::EDAM::Type::Resource.new()
            el.mime = MIME::Types.type_for(@file)[0].content_type
            el.data = ::Evernote::EDAM::Type::Data.new()
            el.data.size = read_file.size
            el.data.bodyHash = Digest::MD5.hexdigest(read_file)
            el.data.body = read_file
            el.attributes = ::Evernote::EDAM::Type::ResourceAttributes.new()
            el.attributes.fileName = @file # temporary for now, the actual file name
            el
          end
        end
    end
  end
end

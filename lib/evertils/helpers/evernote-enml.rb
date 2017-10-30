module Evertils
  module Helper
    class EvernoteENML
      attr_reader :element, :embeddable_element

      # TODO: refactor this whole class so you can create ENML elements with it
      def initialize(file = nil)
        @file = file
        @element = enml_element

        if !@element.nil?
          @embeddable_element = "<hr/>Attachment with hash #{@element.data.bodyHash}<br /><en-media type=\"#{@element.mime}\" hash=\"#{@element.data.bodyHash}\" /><br /><br />"
        end
      end

      def self.with_list(arr)
        enml_bucket = []

        if arr.respond_to? :each_pair
          arr.each_pair do |title, data|
            enml_bucket.push("<br /><div><span style=\"font-size: 18px;\">#{title}</span></div>")

            enml_bucket.push('<ul>')

            data.each do |item|
              enml_bucket.push("<li>#{item}</li>")
            end

            enml_bucket.push('</ul>')
          end

          enml_bucket.join
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

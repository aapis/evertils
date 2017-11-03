module Evertils
  module Helper
    class ApiEnmlHandler
      include Nokogiri::XML

      #
      # @since 0.3.7
      def initialize(config = nil)
        @config = config
        self
      end

      #
      # @since 0.3.13
      def from_str(str)
        @xml = DocumentFragment.parse(str)

        # sometimes, the Doctype declaration gets borked by the XML parser
        # lets replace it with a new DTD if that is the case
        if @xml.children[1].is_a?(Text)
          # remove the existing broken DTD
          @xml.children[1].remove
          # create a new one (note: output is overridden in DTD class defined
          # below ApiEnmlHandler)
          dtd = DTD.new('DOCTYPE', @xml)

          @xml.children.first.after(dtd)
        end

        @xml
      end

      #
      # @since 0.3.7
      def convert_to_xml(enml)
        # remove the xml declaration and DTD
        enml = enml.split("\n")
        enml.shift(2)

        @xml = from_str(enml.join)
        self
      end
      alias to_xml convert_to_xml

      #
      # @since 0.3.5
      def prepare
        note_xml = @xml.search('en-note')

        # remove <br> tags
        note_xml.search('br').each(&:remove)
        note_xml.inner_html.to_s
      end

      #
      # @since 0.3.1
      def to_enml(hash)
        Evertils::Helper::EvernoteENML.with_list(hash)
      end
    end

    # gross hack to get around nokogiri failing to parse the DTD
    class DTD < Nokogiri::XML::DTD
      def to_s
        return "\n<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n"
      end
    end
  end
end

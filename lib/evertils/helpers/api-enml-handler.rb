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
        str.sub!("\n", '')
        @xml = DocumentFragment.parse(str) do |conf|
          conf.noblanks
        end

        fix_dtd
        clear_empty
      end

      #
      # @since 0.3.7
      def convert_to_xml(enml)
        @xml = from_str(enml)
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
      # @since 0.3.15
      def clear_empty
        @xml.css('div').each do |node|
          children = node.children

          if children.size == 1 && children.first.is_a?(Nokogiri::XML::Text)
            node.remove if node.text.strip == ''
          end
        end

        @xml
      end

      # Sometimes, the Doctype declaration gets borked by the XML parser
      # lets replace it with a new DTD if that is the case
      # @since 0.3.15
      def fix_dtd
        if @xml.children[0].is_a?(Text)
          # remove the existing broken DTD
          @xml.children[0].remove
          # create a new one (note: output is overridden in DTD class defined
          # below ApiEnmlHandler)
          dtd = DTD.new('DOCTYPE', @xml)

          @xml.children.first.before(dtd)
        end
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
        return "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">\n"
      end
    end
  end
end

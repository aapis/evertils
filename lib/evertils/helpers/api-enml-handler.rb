module Evertils
  module Helper
    class ApiEnmlHandler
      #
      # @since 0.3.7
      def initialize(config = nil)
        @config = config
        self
      end

      #
      # @since 0.3.13
      def from_str(str)
        @xml = Nokogiri::XML::DocumentFragment.parse(str)
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
  end
end

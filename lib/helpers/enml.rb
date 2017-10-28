module Evertils
  module Helper
    class Enml
      #
      # @since 0.3.7
      def initialize(enml)
        # remove the xml declaration and DTD
        enml = enml.split("\n")
        enml.shift(2)

        @xml = Nokogiri::XML::DocumentFragment.parse(enml.join)
      end

      #
      # @since 0.3.5
      def prepare
        note_xml = @xml.search('en-note')

        # remove <br> tags
        note_xml.search('br').each do |br|
          br.remove
        end

        enml = note_xml.inner_html.to_s

        # append custom sections to the end of the content if they exist
        return enml if $config.custom_sections.nil?

        enml += to_enml($config.custom_sections[NOTEBOOK_PRIORITY_QUEUE])
        enml
      end

      #
      # @since 0.3.1
      def to_enml(hash)
        Evertils::Helper::EvernoteENML.with_list(hash)
      end
    end
  end
end
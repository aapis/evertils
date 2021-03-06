module Evertils
  module Helper
    class Xml < Base
      attr_accessor :doc

      #
      # @since 0.3.15
      def initialize(doc)
        raise ArgumentError, "doc param required" unless doc

        @doc = doc.first
      end

      #
      # @since 0.3.15
      def a(link, content)
        conf = {
          href: link,
          content: content
        }

        create(:a, conf)
      end

      #
      # @since 0.3.18
      def span(content)
        conf = {
          content: content
        }

        create(:span, conf)
      end

      #
      # @since 0.3.15
      def br
        create(:br)
      end

      #
      # @since 0.3.15
      def li(*children)
        el = create(:li)
        children.each { |child| el.add_child(child) }
        el
      end

      #
      # @since 0.3.15
      def div(*children)
        el = create(:div)
        children.each { |child| el.add_child(child) }
        el
      end

      #
      # @since 0.3.18
      def ul(*children)
        el = create(:ul)
        children.each { |child| el.add_child(child) }
        el
      end

      #
      # @since 0.3.15
      def create(element, conf = {})
        el = Nokogiri::XML::Node.new(element.to_s, @doc)

        return el if conf.empty?

        conf.each_pair do |k, v|
          if el.respond_to? "#{k}="
            el.send("#{k}=", v)
          elsif el.respond_to? k
            el.send(k, v)
          else
            el[k] = v
          end
        end

        el
      end
    end
  end
end

# frozen_string_literal: true

module Evertils
  class Grammar
    attr_accessor :tags, :notebook, :created, :intitle

    # Available grammars
    # https://dev.evernote.com/doc/articles/search_grammar.php
    # @since 1.0.12
    def initialize
      @tags = []
      @grammar = []
      @notebook = nil
      @intitle = nil
      @created = Date.today.strftime('%Y%m%d')
    end

    #
    # @since 1.0.12
    def to_s
      stringify_properties
      stringify_tags unless @tags.empty?

      @grammar.join(' ')
    end

    private

    #
    # @since 1.0.12
    def stringify_tags
      @tags.each_pair do |k, v|
        @grammar.push("tag:#{k}-#{v}")
      end
    end

    #
    # @since 1.0.12
    def stringify_properties
      # automatically convert the non-hash properties to EN grammar key/value
      # pairs
      grammars_used = methods - Object.instance_methods
      grammars_used.reject! { |k, _| k.to_s.end_with?('=') || k == :tags }

      grammars_used.each do |grammar|
        value = send(grammar)
        @grammar.push("#{grammar}:#{value}") unless value.nil?
      end
    end
  end
end

# frozen_string_literal: true

require 'ostruct'

module Evertils
  class Type
    attr_reader :params

    def initialize(path)
      begin
        type_path = File.expand_path(path)
        contents = YAML.load_file(type_path)

        return if contents.empty?

        translate_variables(contents)

        @params = OpenStruct.new(contents)
      rescue Errno::ENOENT
        Notify.error("File doesn't exist - #{type_path}")
      end
    end

    private

    def translate_variables(hash)
      title_format = hash[:title].dup

      hash.map do |item|
        break if item.last.is_a? Hash

        Evertils::Cfg::REPLACEMENTS.each_pair do |k, v|
          item.last.gsub!(k.to_s, v.to_s) if item.last.is_a? String
          item.last.map { |i| break if i.is_a? Hash; i.gsub!(k.to_s, v.to_s) } if item.last.is_a? Array
        end
      end

      hash[:title_format] = title_format unless hash.key? :title_format

      Evertils::Helper::Formatting.symbolize_keys(hash)
    end
  end
end

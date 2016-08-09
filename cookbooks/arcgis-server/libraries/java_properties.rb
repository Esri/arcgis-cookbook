module JavaProperties
  module Encoding
    # Module to escape and unescape special chars
    # @see JavaProperties::Encoding
    module SpecialChars
      # Lookup table for escaping special chars
      # @return [Hash]
      ESCAPING = {
        "\t" => '\\t',
        "\r" => '\\r',
        "\n" => '\\n',
        "\f" => '\\f'
      }.freeze

      # Lookup table to remove escaping from special chars
      # @return [Hash]
      DESCAPING = ESCAPING.invert.freeze

      # Marks a segment which has is an encoding special char
      # @return [Regexp]
      DESCAPING_MARKER = /\\./

      # Encodes the content a text by escaping all special chars
      # @param text [String]
      # @return [String] The escaped text for chaining
      def self.encode!(text)
        buffer = StringIO.new
        text.each_char do |char|
          buffer << ESCAPING.fetch(char, char)
        end
        text.replace buffer.string
        text
      end

      # Decodes the content a text by removing all escaping from special chars
      # @param text [String]
      # @return [String] The unescaped text for chaining
      def self.decode!(text)
        text.gsub!(DESCAPING_MARKER) do |match|
          DESCAPING.fetch(match, match)
        end
        text
      end
    end
  end
end

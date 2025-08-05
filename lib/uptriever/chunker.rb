# frozen_string_literal: true

require "nokogiri"

module Uptriever
  # Splits HTML into smaller chunks by h2 headers
  class Chunker
    attr_reader :chunk

    def initialize(chunk)
      @chunk = chunk
    end

    def chunks
      doc = Nokogiri::HTML(chunk.fetch(:chunk_html))
      header = doc.at_css("h1")
      return [chunk_dup] unless header

      # Root chunks are usually less specific, so make them weigh less
      root_chunk = chunk_dup.tap {
        _1[:weight] = 1.5
        _1[:metadata] = {title: doc.at_css("h1").inner_text}
      }
      doc.xpath("//body").children.each_with_object([root_chunk]) do |child, acc|
        # Start new chunk
        if child.name == "h2"
          anchor = child.inner_text.downcase.gsub(/[^a-z0-9]/, "-")
          acc << chunk_dup.tap {
            _1.merge!(
              link: "#{_1.fetch(:link)}?id=#{anchor}",
              tracking_id: "#{_1.fetch(:tracking_id)}##{anchor}",
              metadata: {title: child.inner_text}
            )
          }
          next acc
        end

        acc.last[:chunk_html] << child.to_xhtml
      end
    end

    private

    def chunk_dup = chunk.dup
  end
end

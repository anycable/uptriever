# frozen_string_literal: true

require "test_helper"

module Uptriever
  class ChunkerTest < TestCase
    def setup
      @chunk = {chunk_html: "<h1>Title</h1>", link: "http://example.com", tracking_id: "root"}
      @chunker = Chunker.new(@chunk)
    end

    def test_chunks_with_empty_html
      @chunker.chunk[:chunk_html] = ""
      chunks = @chunker.chunks
      assert_equal 1, chunks.size
    end

    def test_chunks_with_single_h1_html
      chunks = @chunker.chunks
      assert_equal "Title", chunks.first[:metadata][:title]
    end

    def test_chunks_with_h2_splitting
      @chunker.chunk[:chunk_html] = "<h1>Title</h1><h2>Section 1</h2><p>Content 1</p><h2>Section 2</h2><p>Content 2</p>"
      chunks = @chunker.chunks
      assert_equal 3, chunks.size
      assert chunks[1][:link].include?("?id=section-1")
      assert_equal "root#section-1", chunks[1][:tracking_id]
      assert_equal "Section 1", chunks[1][:metadata][:title]
      assert chunks[2][:chunk_html].include?("Content 2")
    end

    def test_chunks_with_non_h2_content
      @chunker.chunk[:chunk_html] = "<h1>Title</h1><p>Intro</p>"
      chunks = @chunker.chunks
      assert_equal 1, chunks.size
      assert chunks.first[:chunk_html].include?("Intro")
    end
  end
end

# frozen_string_literal: true

require "test_helper"

module Uptriever
  class DocumentTest < TestCase
    def setup
      @markdown_content = "# Hello World\nThis is a test."
      @html_content = "<h1>Hello World</h1><p>This is a test.</p>"
      @markdown_file = Tempfile.new(["test", ".md"])
      @html_file = Tempfile.new(["test", ".html"])
      @unsupported_file = Tempfile.new(["test", ".txt"])

      @markdown_file.write(@markdown_content)
      @html_file.write(@html_content)
      @unsupported_file.write("Just some text.")

      @markdown_file.rewind
      @html_file.rewind
      @unsupported_file.rewind
    end

    def teardown
      @markdown_file.close
      @html_file.close
      @unsupported_file.close
    end

    def test_initialization
      doc = Document.new(1, "path/to/file", "http://example.com", tags: ["tag1", "tag2"], groups: [1, 2], weight: 2.0)
      assert_equal 1, doc.id
      assert_equal "path/to/file", doc.path
      assert_equal "http://example.com", doc.link
      assert_equal ["tag1", "tag2"], doc.tags
      assert_equal [1, 2], doc.groups
      assert_equal 2.0, doc.weight
    end

    def test_to_html_with_markdown
      doc = Document.new(1, @markdown_file.path, "http://example.com")
      expected_html = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true).render(@markdown_content)
      assert_equal expected_html.strip, doc.to_html.strip
    end

    def test_to_html_with_html
      doc = Document.new(1, @html_file.path, "http://example.com")
      assert_equal @html_content, doc.to_html
    end

    def test_to_html_with_unsupported_file
      doc = Document.new(1, @unsupported_file.path, "http://example.com")
      assert_raises(ArgumentError) { doc.to_html }
    end

    def test_to_chunk_json_without_tags_groups
      doc = Document.new(1, @html_file.path, "http://example.com")
      expected_json = {
        chunk_html: @html_content,
        link: "http://example.com",
        tracking_id: 1,
        weight: 1.0
      }
      assert_equal expected_json, doc.to_chunk_json
    end

    def test_to_chunk_json_with_tags_groups
      doc = Document.new(1, @html_file.path, "http://example.com", tags: ["tag1"], groups: [1])
      expected_json = {
        chunk_html: @html_content,
        link: "http://example.com",
        tracking_id: 1,
        weight: 1.0,
        tag_set: ["tag1"],
        group_tracking_ids: [1]
      }
      assert_equal expected_json, doc.to_chunk_json
    end
  end
end

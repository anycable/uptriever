# frozen_string_literal: true

require "redcarpet"
require "front_matter_parser"
require "front_matter_parser/syntax_parser"
FrontMatterParser::SyntaxParser::Mdx = FrontMatterParser::SyntaxParser::Md

module Uptriever
  class Document
    attr_reader :id, :path, :link, :tags, :groups, :weight

    def initialize(id, path, link, tags: nil, groups: nil, weight: 1.0)
      @id = id
      @path = path
      @link = link
      @tags = tags
      @groups = groups
      @weight = weight
    end

    def to_html
      case File.extname(path)
      when ".md", ".mdx"
        parsed = FrontMatterParser::Parser.parse_file(path)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
        markdown.render(parsed.content)
      when ".html"
        File.read(path)
      else
        raise ArgumentError, "Unsupported file type: #{path}"
      end
    end

    def to_chunk_json
      {
        chunk_html: +to_html,
        link:,
        tracking_id: id,
        weight:
      }.tap do
        _1.merge!(tag_set: tags) if tags
        _1.merge!(group_tracking_ids: groups) if groups
      end
    end
  end
end

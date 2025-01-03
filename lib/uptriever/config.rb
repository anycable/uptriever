# frozen_string_literal: true

require "yaml"
require "erb"

module Uptriever
  class Config
    def self.parse(path) = new(path).documents

    attr_reader :config_path, :root_dir

    def initialize(root_dir)
      @root_dir = File.expand_path(root_dir)
      @config_path = File.join(root_dir, ".trieve.yml")
      raise ArgumentError, ".trieve.yml is missing in the #{root_dir}" unless File.file?(config_path)
    end

    def groups
      config["groups"] || []
    end

    def documents
      pages = unwrap_pages(config["pages"])

      defaults = (config["defaults"] || {}).transform_keys(&:to_sym)

      pages.filter_map do |page|
        next if config["ignore"]&.any? { File.fnmatch?(_1, page["source"]) }

        relative_link = page["source"].sub(root_dir, "").sub(/\.[^\.]+$/, "").then do
          next _1 unless config["url_prefix"]
          File.join(config["url_prefix"], _1)
        end

        link = page["link"] || File.join(config.fetch("hostname"), relative_link)
        id = page["id"] || relative_link.sub(/^\//, "").gsub(/[\/-]/, "-")

        Document.new(id, page["source"], link, **defaults.merge({groups: page["groups"], tags: page["tags"], weight: page["weight"]}.compact))
      end
    end

    private

    def config
      @config ||= YAML.load(ERB.new(File.read(config_path)).result)
    end

    def unwrap_pages(items)
      items.flat_map do |item|
        if item.is_a?(String)
          Dir.glob(File.expand_path(File.join(root_dir, item))).map { {"source" => _1} }
        else
          Dir.glob(File.expand_path(File.join(root_dir, item.fetch("source")))).map do
            new_item = item.dup
            new_item["source"] = _1
            new_item
          end
        end
      end
    end
  end
end

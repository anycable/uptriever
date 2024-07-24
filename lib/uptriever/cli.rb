# frozen_string_literal: true

require "uptriever"
require "ruby-progressbar"
require "optparse"

module Uptriever
  class CLI
    def run(args = [])
      @docs_dir = File.join(Dir.pwd, "docs")
      @api_key = ENV["TRIEVE_API_KEY"]
      @dataset = ENV["TRIEVE_DATASET"]
      @dry_run = false

      # Add optparser to parse options: --dir, --api_key, --dataset, --dry-run
      OptionParser.new do |opts|
        opts.banner = "Usage: uptriever [options]"
        opts.on("-d", "--dir DIR", "Directory with documents") do |dir|
          @docs_dir = dir
        end
        opts.on("-k", "--api-key API_KEY", "Trieve API key") do |key|
          @api_key = key
        end
        opts.on("-s", "--dataset DATASET", "Trieve dataset") do |dataset|
          @dataset = dataset
        end
        opts.on("--dry-run", "Dry run mode") do
          @dry_run = true
        end
      end.parse!(args)

      config = Config.new(@docs_dir)
      client = Client.new(@api_key, @dataset, dry_run: @dry_run)

      groups = config.groups
      if groups.any?
        progressbar = ProgressBar.create(title: "Groups", total: groups.size)
        groups.each do
          client.push_group(_1)
          progressbar.increment
        end
      end

      chunks = config.documents.flat_map { Chunker.new(_1.to_chunk_json).chunks }
      progressbar = ProgressBar.create(title: "Chunks", total: chunks.size)
      chunks.each do
        client.push_chunk(_1)
        progressbar.increment
      end
    end
  end
end

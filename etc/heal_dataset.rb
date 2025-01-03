#!/usr/bin/env ruby
# frozen_string_literal: true

# A script to remove broken chunks from the dataset, i.e., chunks matching the given link pattern

require "uptriever"
require "ruby-progressbar"

client = Uptriever::Client.new

pattern = Regexp.new(Regexp.escape(ARGV[0]))

matching_chunks = Set.new

usage = client.usage

puts "Total chunks: #{usage["chunk_count"]}"

progressbar = ProgressBar.create(title: "Scroll chunks", total: usage["chunk_count"])

client.scroll_chunks do |chunk|
  progressbar.increment
  if chunk["link"] =~ pattern
    matching_chunks << chunk["id"]
  end
end

puts "Found #{matching_chunks.size} chunks to delete.\nDeleting...\n"
progressbar = ProgressBar.create(title: "Chunks", total: matching_chunks.size)

matching_chunks.each do
  client.delete_chunk(_1)
  progressbar.increment
end

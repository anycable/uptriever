#!/usr/bin/env ruby
# frozen_string_literal: true

# A script to remove broken chunks from the dataset, i.e., chunks matching the given link pattern

require "uptriever"
require "ruby-progressbar"

client = Uptriever::Client.new

chunks = {}

usage = client.usage

puts "Total chunks: #{usage["chunk_count"]}"

progressbar = ProgressBar.create(title: "Scroll chunks", total: usage["chunk_count"])

client.scroll_chunks do |chunk|
  progressbar.increment
  chunks[chunk["id"]] = chunk
end

chunks.each_value do |chunk|
  puts "Chunk [#{chunk["id"]}]: #{chunk["link"]}"
end

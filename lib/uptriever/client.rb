# frozen_string_literal: true

require "net/http"
require "json"

module Uptriever
  class Client
    BASE_URL = "https://api.trieve.ai/api"

    attr_reader :headers
    private attr_reader :dry_run, :dataset_id

    def initialize(api_key = ENV["TRIEVE_API_KEY"], dataset = ENV["TRIEVE_DATASET"], dry_run: false)
      @dataset_id = dataset
      @dry_run = dry_run
      @headers = {
        "Authorization" => api_key,
        "TR-Dataset" => dataset
      }.freeze
    end

    def push_group(group, upsert: true)
      group[:upsert_by_tracking_id] = upsert
      perform_request("/chunk_group", group.to_json)
    end

    def push_chunk(chunk, upsert: true)
      chunk[:upsert_by_tracking_id] = upsert
      perform_request("/chunk", chunk.to_json).inspect
    end

    def scroll_chunks(per_page: 100)
      data = {
        filters: {must: nil},
        page_size: per_page
      }

      offset_id = nil

      loop do
        data[:offset_chunk_id] = offset_id if offset_id
        data = perform_request("/chunks/scroll", data.to_json)

        chunks = data.fetch("chunks")
        chunks = chunks.select { _1["id"] != offset_id } if offset_id

        break if chunks.empty?

        chunks.each { yield _1 }

        offset_id = chunks.last["id"]
      end
    end

    def delete_chunk(id)
      perform_request("/chunk/#{id}", method: :delete, expected_code: 204)
    end

    def usage
      perform_request("/dataset/usage/#{dataset_id}", method: :get)
    end

    private

    def perform_request(path, data = nil, method: :post, expected_code: 200)
      uri = URI.parse(BASE_URL + path)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP.const_get(method.to_s.capitalize).new(
        uri.request_uri,
        headers.merge("Content-Type" => "application/json")
      )
      request.body = data if data

      if dry_run
        puts "[DRY RUN] Perform POST #{path}: #{data}"
        return
      end

      response = http.request(request)

      if response.code.to_i != expected_code
        raise "Invalid response code: #{response.code} (#{response.body[100...]})"
      end

      JSON.parse(response.body) if response.body
    end
  end
end

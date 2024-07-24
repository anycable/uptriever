# frozen_string_literal: true

require "net/http"
require "json"

module Uptriever
  class Client
    BASE_URL = "https://api.trieve.ai/api"

    attr_reader :headers
    private attr_reader :dry_run

    def initialize(api_key, dataset, dry_run: false)
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
      perform_request("/chunk", chunk.to_json)
    end

    private

    def perform_request(path, data)
      uri = URI.parse(BASE_URL + path)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.scheme == "https"

      request = Net::HTTP::Post.new(
        uri.request_uri,
        headers.merge("Content-Type" => "application/json")
      )
      request.body = data

      if dry_run
        puts "[DRY RUN] Perform POST #{path}: #{data}"
        return
      end

      response = http.request(request)

      if response.code.to_i != 200
        raise "Invalid response code: #{response.code} (#{response.body[100...]})"
      end

      JSON.parse(response.body)
    end
  end
end

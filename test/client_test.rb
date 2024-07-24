# frozen_string_literal: true

require "test_helper"

module Uptriever
  class ClientTest < TestCase
    def setup
      WebMock.disable_net_connect!
      @api_key = "test_api_key"
      @dataset = "test_dataset"
      @client = Client.new(@api_key, @dataset)
    end

    def test_push_group
      stub_request(:post, "https://api.trieve.ai/api/chunk_group")
        .with(
          headers: {
            "Authorization" => @api_key,
            "TR-Dataset" => @dataset,
            "Content-Type" => "application/json"
          },
          body: hash_including(upsert_by_tracking_id: true)
        )
        .to_return(status: 200, body: '{"success": true}', headers: {})

      assert @client.push_group({name: "test_group"})
    end

    def test_push_chunk
      stub_request(:post, "https://api.trieve.ai/api/chunk")
        .with(
          headers: {
            "Authorization" => @api_key,
            "TR-Dataset" => @dataset,
            "Content-Type" => "application/json"
          },
          body: hash_including(upsert_by_tracking_id: true)
        )
        .to_return(status: 200, body: '{"success": true}', headers: {})

      assert @client.push_chunk({content: "test_chunk"})
    end

    def test_error_handling
      stub_request(:post, "https://api.trieve.ai/api/chunk")
        .to_return(status: 500, body: "Internal Server Error")

      assert_raises(RuntimeError) { @client.push_chunk({content: "test_chunk"}) }
    end

    def test_dry_run_no_request_made
      @client = Uptriever::Client.new(@api_key, @dataset, dry_run: true)

      stub_request(:any, //).to_raise("No request should be made in dry run mode")

      captured_output, _ = capture_output do
        @client.push_chunk({content: "test_chunk"})
      end

      # Assert that a specific line has been printed to stdout
      assert_includes captured_output, "[DRY RUN] Perform POST /chunk"

      assert_not_requested :any, //
    end
  end
end

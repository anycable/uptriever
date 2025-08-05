# frozen_string_literal: true

require "test_helper"

module Uptriever
  class ConfigTest < TestCase
    def setup
      @root_dir = "./test/fixtures/docs"
      @config_path = File.join(@root_dir, ".trieve.yml")
      @config = Config.new(@root_dir)
    end

    def test_initialization_file_missing
      assert_raises(ArgumentError) { Config.new(@root_dir + "foo") }
    end

    def test_groups_returns_defined_groups
      assert_equal [{"name" => "Server", "tracking_id" => "server"}, {"name" => "Client", "tracking_id" => "client"}], @config.groups
    end

    def test_erb
      ENV["URL_PREFIX"] = "/v1-3"
      docs = @config.documents

      assert_equal "https://docs.anycable.io/v1-3/js/setup", docs.first.link
    ensure
      ENV.delete("URL_PREFIX")
    end

    def test_double_slashes
      ENV["URL_PREFIX"] = "//latest/subpath"
      docs = @config.documents

      assert_equal "https://docs.anycable.io/latest/subpath/js/setup", docs.first.link
    ensure
      ENV.delete("URL_PREFIX")
    end
  end
end

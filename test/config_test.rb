# frozen_string_literal: true

require "test_helper"

module Uptriever
  class ConfigTest < TestCase
    def setup
      @root_dir = File.join(__dir__, "fixtures", "docs")
      @config_path = File.join(@root_dir, ".trieve.yml")
      @config = Config.new(@root_dir)
    end

    def test_initialization_file_missing
      assert_raises(ArgumentError) { Config.new(@root_dir + "foo") }
    end

    def test_groups_returns_defined_groups
      assert_equal [{"name" => "Server", "tracking_id" => "server"}, {"name" => "Client", "tracking_id" => "client"}], @config.groups
    end
  end
end

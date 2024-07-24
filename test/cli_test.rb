# frozen_string_literal: true

require "test_helper"

require "uptriever/cli"

module Uptriever
  class CLITest < TestCase
    def test_cli_run
      @cli = CLI.new

      output, _ = capture_output do
        Dir.chdir(File.join(__dir__, "fixtures")) do
          @cli.run(["--dry-run"])
        end
      end

      # Verify groups creation
      assert_includes output, 'Perform POST /chunk_group: {"name":"Server"'
      assert_includes output, 'Perform POST /chunk_group: {"name":"Client"'

      # Verify file scanning
      assert_includes output, "https://docs.anycable.io/anycable-test/js/setup"
      refute_includes output, "https://docs.anycable.io/anycable-test/js/Readme"

      # Verify progressbar
      assert_includes output, "Groups: |"
      assert_includes output, "Chunks: |"
    end
  end
end

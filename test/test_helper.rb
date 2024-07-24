# frozen_string_literal: true

begin
  require "debug" unless ENV["CI"]
rescue LoadError
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "uptriever"

require "webmock/minitest"

Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"

class Uptriever::TestCase < Minitest::Test
  def capture_output
    captured_stdout = StringIO.new
    captured_stderr = StringIO.new
    original_stdout = $stdout
    original_stderr = $stderr
    $stdout = captured_stdout
    $stderr = captured_stderr

    if defined?(::ProgressBar)
      ProgressBar::Output.send(:remove_const, :DEFAULT_OUTPUT_STREAM)
      ProgressBar::Output.const_set(:DEFAULT_OUTPUT_STREAM, $stdout)
    end

    yield

    [captured_stdout.string, captured_stderr.string]
  ensure
    # Reset stdout
    $stdout = original_stdout
    $stderr = original_stderr
    if defined?(::ProgressBar)
      ProgressBar::Output.send(:remove_const, :DEFAULT_OUTPUT_STREAM)
      ProgressBar::Output.const_set(:DEFAULT_OUTPUT_STREAM, $stdout)
    end
  end
end

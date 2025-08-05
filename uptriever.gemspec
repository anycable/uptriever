# frozen_string_literal: true

require_relative "lib/uptriever/version"

Gem::Specification.new do |s|
  s.name = "uptriever"
  s.version = Uptriever::VERSION
  s.authors = ["Vladimir Dementyev"]
  s.email = ["Vladimir Dementyev"]
  s.homepage = "https://github.com/palkan/uptriever"
  s.summary = "Upload documenbts to Trieve"
  s.description = "Upload documenbts to Trieve"

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/palkan/uptriever/issues",
    "changelog_uri" => "https://github.com/palkan/uptriever/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/palkan/uptriever",
    "homepage_uri" => "https://github.com/palkan/uptriever",
    "source_code_uri" => "https://github.com/palkan/uptriever"
  }

  s.license = "MIT"

  s.executables = %w[uptriever]
  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.1"

  s.add_dependency "redcarpet", "~> 3.6"
  s.add_dependency "nokogiri"
  s.add_dependency "yaml"
  s.add_dependency "ruby-progressbar"
  s.add_dependency "uri"
  s.add_dependency "json"
  s.add_dependency "optparse"
  s.add_dependency "erb"
  s.add_dependency "front_matter_parser"

  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "webmock", "~> 3.23"
end

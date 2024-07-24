[![Gem Version](https://badge.fury.io/rb/uptriever.svg)](https://rubygems.org/gems/uptriever)
[![Build](https://github.com/palkan/uptriever/workflows/Build/badge.svg)](https://github.com/palkan/uptriever/actions)

# Uptriever

Uptriever is a CLI to upload documentation source file (HTML, Markdown) to [Trieve][] for search indexing.

## Installation

Install Uptreiver as a Ruby gem (Ruby 3.1+ is required):

```sh
gem install uptriever
```

## Usage

Currently, Uptriever requires an index configuration file (`.trieve.yml`) to be present in the documentation root folder containing the list of files to index and their metadata. A minimal example of indexing everything looks as follows:

```yml
hostname: https://myproject.example/docs
pages:
  - "**/*.md"
```

The `hostname` field is used to generate the `link` property for chunks (see [Trieve API](https://docs.trieve.ai/api-reference/chunk/create-or-upsert-chunk-or-chunks)).

The `pages` field contains the list of pages to index. It supports glob patterns.

With config in place, you can run the `uptriever` executable to perform the indexing:

```sh
$ uptriever -d ./docs --api-key=<Trieve API key> --dataset=<Trieve dataset>

Groups: |===========================|
Chunks: |===========================|
```

## Full-featured example

Why do we need a configuration file? To leverage Trieve features such as groups, tags, and weights. Here is a real-life example:

```yml
# Ignore patterns for globs in pages
ignore:
 - "**/*/Readme.md"
hostname: https://docs.anycable.io
# Prepend file paths with this prefix.
# Useful when you store documentation in multiple sources.
url_prefix: anycable-go/

# Make sure the following chunk groups are created
groups:
  - name: PRO version
    tracking_id: pro
  - name: Server
    tracking_id: server
  - name: Client
    tracking_id: client
  - name: Go package
    tracking_id: package

# Default metadata for pages (can be overriden)
defaults:
  groups: ["server"]
  tags: ["docs"]

pages:
  # You can use a dictionary to define source paths
  # along with metadata
  - source: "./apollo.md"
    groups: ["pro", "server"]
  - source: "./binary_formats.md"
    groups: ["pro", "server", "client"]
  - "./broadcasting.md"
  - "./broker.md"
  - "./health_checking.md"
  - "./instrumentation.md"
  - source: "./library.md"
    groups: ["package"]
  - "./pubsub.md"
  - source: "./js/**/*.md"
    groups: ["client"]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/palkan/uptriever](https://github.com/palkan/uptriever).

## Credits

This gem is generated via [`newgem` template](https://github.com/palkan/newgem) by [@palkan](https://github.com/palkan).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[Trieve]: https://trieve.ai

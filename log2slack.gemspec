# frozen_string_literal: true

require_relative "lib/log2slack/version"

Gem::Specification.new do |spec|
  spec.name = "log2slack"
  spec.version = Log2slack::VERSION
  spec.authors = ["delightech"]
  spec.email = ["hisafumi.kikkawa@gmail.com"]

  spec.summary = "Send log summaries to slack webhook."
  spec.description = "Send log summaries to slack webhook."
  spec.homepage = "https://github.com/delightech/log2slack"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/delightech/log2slack"
  spec.metadata["changelog_uri"] = "https://github.com/delightech/log2slack"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Register dependencies of the gem
  spec.add_dependency "slack-notifier", "~> 2.3.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

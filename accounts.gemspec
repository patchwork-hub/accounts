# frozen_string_literal: true

require_relative "lib/accounts/version"

Gem::Specification.new do |spec|
  spec.name = "accounts"
  spec.version = Accounts::VERSION
  spec.authors = ["Aung Kyaw Phyo"]
  spec.email = ["kiru.kiru28@gmail.com"]

  spec.summary = "Overrides Register, Notification tokens, Push notification"
  spec.description = "A custom gem to dynamically override the Mastodon Register and Notification features"
  spec.homepage = "https://www.joinpatchwork.org/"
  spec.license = "AGPL-3.0"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 8.0"
  spec.add_dependency "byebug", "~> 11.1"
  spec.add_dependency 'googleauth', '~> 1.13', '>= 1.13.1'
  spec.add_dependency 'httparty', "~> 0.23.1"
end

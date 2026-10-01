Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem "canon"
  gem "relaton", ">= 3.0.0.pre.alpha", "< 4" # the model fixtures; the engine itself is model-agnostic
  gem "debug"
  gem "iso-690-test-suite", github: "relaton/iso-690-test-suite"
  gem "rake", ">= 12.3.3"
  gem "rspec", "~> 3.0"
  gem "simplecov"
end

begin
  eval_gemfile("Gemfile.devel")
rescue StandardError
  nil
end

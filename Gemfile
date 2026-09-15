Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem "canon"
  gem "debug"
  gem "rake", ">= 12.3.3"
  gem "rspec", "~> 3.0"
  gem "simplecov"
end

eval_gemfile("Gemfile.devel") rescue nil

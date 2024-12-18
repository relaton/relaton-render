lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton/render/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-render"
  spec.version       = Relaton::Render::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Rendering of ISO 690 XML"
  spec.description   = "Rendering of ISO 690 XML"
  spec.homepage      = "https://github.com/relaton/relaton-render"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"

  spec.add_dependency "isodoc-i18n", "~> 1.3.0"
  spec.add_dependency "liquid", "~> 5"
  spec.add_dependency "nokogiri"
  spec.add_dependency "relaton-bib", ">= 1.20.0"
  spec.add_dependency "twitter_cldr"
  spec.add_dependency "tzinfo-data" # we need this for windows only
  spec.add_dependency "base64" # Liquid
  spec.add_dependency "bigdecimal" # Liquid
  #spec.metadata["rubygems_mfa_required"] = "true"
end

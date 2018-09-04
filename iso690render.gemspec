
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iso690render/version"

Gem::Specification.new do |spec|
  spec.name          = "iso690render"
  spec.version       = Iso690Render::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = %q{Rendering of ISO 690 XML}
  spec.description   = %q{Rendering of ISO 690 XML}
  spec.homepage      = "https://github.com/riboseinc/iso690render"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"

  spec.add_dependency 'nokogiri'
  spec.add_dependency "twitter_cldr"
end

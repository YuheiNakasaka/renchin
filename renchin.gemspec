# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'renchin/version'

Gem::Specification.new do |spec|
  spec.name          = "renchin"
  spec.version       = Renchin::VERSION
  spec.authors       = ["YuheiNakasaka"]
  spec.email         = ["yuhei.nakasaka@gmail.com"]

  spec.summary       = %q{Renchin is a convinient cli wrapper library to convert movie to image/movie/gif or convert image to image/movie/gif}
  spec.description   = %q{Renchin is a convinient cli wrapper library to convert movie to image/movie/gif or convert image to image/movie/gif}
  spec.homepage      = "https://github.com/YuheiNakasaka/renchin"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end

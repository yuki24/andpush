# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'andpush/version'

Gem::Specification.new do |spec|
  spec.name          = "andpush"
  spec.version       = Andpush::VERSION
  spec.authors       = ["Yuki Nishijima"]
  spec.email         = ["mail@yukinishijima.net"]
  spec.summary       = %q{Simple, fast, high-quality client for FCM (Firebase Cloud Messaging)}
  spec.description   = %q{Android Push Notification in Ruby: simple, fast, high-quality client for FCM (Firebase Cloud Messaging)}
  spec.homepage      = "https://github.com/yuki24/andpush"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject {|f| f.match(%r{^(test)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'net-http-persistent', '>= 3.0.0'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mountain-goat/version"

Gem::Specification.new do |s|
  s.name        = "mountain-goat"
  s.version     = MountainGoat::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Geoffrey Hayes", "meloncard.com"]
  s.email       = ["geoff@meloncard.com"]
  s.homepage    = "http://github.com/hayesgm/mountain_goat"
  s.summary     = "A/B Testing to the edge"
  s.description = "A/B test everything and get awesome in-house analytics"

  s.rubyforge_project = "mountain-goat"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development Dependencies
  s.add_development_dependency(%q<rspec>, ["~> 2.2.0"])
  s.add_development_dependency(%q<rack-test>, [">= 0.5.6"])
end


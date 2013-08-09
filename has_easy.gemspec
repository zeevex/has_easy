# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "has_easy/version"

Gem::Specification.new do |s|
  s.name        = "has_easy"
  s.version     = HasEasy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Sanders"]
  s.email       = ["robert@zeevex.com"]
  s.homepage    = "https://github.com/zeevex/has_easy"
  s.summary     = %q{Our forked gemified version of the old has_easy Rails plugin}
  s.description = %q{Easy access and creation of "has many" relationships. This is Zeevex's forked and gemified version.}

  s.rubyforge_project = "has_easy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'rake'
end

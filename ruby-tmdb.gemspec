# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ruby-tmdb/version"

Gem::Specification.new do |s|
  s.name        = "ruby-tmdb"
  s.version     = Ruby::Tmdb::VERSION
  s.authors     = ["Aaron Gough"]
  s.email       = ["aaron@aarongough.com"]
  s.homepage    = "https://github.com/aarongough/ruby-tmdb"
  s.summary     = "An ActiveRecord-style API wrapper for TheMovieDB.org"
  s.description = "An ActiveRecord-style API wrapper for TheMovieDB.org"

  s.rubyforge_project = "ruby-tmdb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "deepopenstruct", ">= 0.1.2"
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "addressable"
  
  s.add_development_dependency "webmock"
  s.add_development_dependency "mocha"
end

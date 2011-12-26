# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "suitcase/version"

Gem::Specification.new do |s|
  s.name        = "suitcase"
  s.version     = Suitcase::VERSION
  s.authors     = ["Walter Nelson"]
  s.email       = ["walter.john.nelson@gmail.com"]
  s.homepage    = "http://github.com/thoughtfusion/suitcase"
  s.summary     = %q{Locates available hotels, rental cars, and flights}
  s.description = %q{Suitcase utilizes the EAN API for locating available hotels, rental cars, and flights.}

  s.rubyforge_project = "suitcase"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "json"
end

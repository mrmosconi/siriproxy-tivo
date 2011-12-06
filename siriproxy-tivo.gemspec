# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "siriproxy-tivo"
  s.version     = "1.0" 
  s.authors     = ["vstar"]
  s.email       = ["mrmosconi@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Plugin to control your TiVo}
  s.description = %q{ Send your TiVo basic commands (e.g., "tivo play, "tivo pause", etc.), and also allow search for programs "tivo search Big Bang Theory". }

  s.rubyforge_project = "siriproxy-tivo"

  s.files         = `git ls-files 2> /dev/null`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/* 2> /dev/null`.split("\n")
  s.executables   = `git ls-files -- bin/* 2> /dev/null`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end

# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "business-hours/version"

Gem::Specification.new do |s|
  s.name        = "business-hours"
  s.version     = BusinessHours::VERSION
  s.authors     = ["Scenetap"]
  s.email       = ["shea@scenetap.com"]
  s.homepage    = "https://github.com/scenetap/business-hours"
  s.summary     = %q{Defines business hours for bars}
  s.description = %q{Defines close and open time for business which are open later then 12am}

  s.rubyforge_project = "business-hours"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_runtime_dependency "chronic"
  s.add_runtime_dependency "tzinfo"
  s.add_runtime_dependency "active_support"
end

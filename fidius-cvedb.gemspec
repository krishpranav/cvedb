$:.push File.expand_path("../lib", __FILE__)
require "fidius-cvedb/version"

Gem::Specification.new do |s|
    s.name = "cvedb"
    s.version = FIDIUS::CveDb::VERSION
    s.platform = Gem::Platform::RUBY
    s.add_dependency('nokogirl')
    s.authors = ['krishpranav']
    s.email = ['']
    s.homepage = "krishpranav.github.io"
    
    s.rubyforge_project = ''

    s.files         = `git ls-files`.split("\n")
    s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
    s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
    s.require_paths = ["lib"]

    s.add_development_dependency 'rake'
end

# -*- encoding: utf-8 -*-
require File.expand_path('../lib/colombo',  __FILE__)

Gem::Specification.new do |s|
  s.name = %q{colombo}
  s.version = Colombo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Jerome Touffe-Blin"]
  s.email = %q{jtblin@gmail.com}
  s.homepage = %q{http://github.com/jtblin/colombo}
  s.summary = %q{Inspector Colombo}
  s.description = %q{Users browsing sessions inspector}
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency(%q<rack>, [">= 1.4.0"])
  s.add_development_dependency      'sinatra'
  #s.add_development_dependency(%q<rack-test>, [">= 0.3.0"])

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end


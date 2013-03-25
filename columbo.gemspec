# -*- encoding: utf-8 -*-
require File.expand_path('../lib/columbo/version', __FILE__)

Gem::Specification.new do |s|
  s.name = %q{columbo}
  s.version = Columbo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors = ["Jerome Touffe-Blin"]
  s.email = %q{jtblin@gmail.com}
  s.homepage = %q{http://github.com/jtblin/columbo-rb}
  s.summary = %q{A Ruby client library for Inspector Columbo}
  s.description = %q{A Ruby client library for Columbo: a Customer Experience Management tool}
  s.required_rubygems_version = ">= 1.3.6"
  s.add_runtime_dependency %q<rack>, [">= 1.4.0"]
  s.add_runtime_dependency %q<nokogiri>, [">= 1.5.9"]
  s.add_runtime_dependency %q<html_mini>, [">= 0.0.2"]
  s.add_runtime_dependency %q<mongo>, [">= 1.6.1"]
  s.add_runtime_dependency %q<bson_ext>, [">= 1.6.1"]
  #s.add_development_dependency %q<rack-test>, [">= 0.3.0"]

  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]

end


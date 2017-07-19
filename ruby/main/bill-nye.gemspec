# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bill-nye/version'

Gem::Specification.new do |gem|
  gem.name          = "bill-nye"
  gem.version       = MediaRequester::VERSION
  gem.authors       = ["Keenin Vye"]
  gem.email         = ["KeeninVye@gmail.com"]
  gem.description   = %q{This library facilitates in the parsing of Chase bank statements.}
  gem.summary       = %q{Just what the description says.}
  gem.homepage      = ""

  gem.add_dependency 'micro-optparse'
  gem.add_dependency 'yajl-ruby'
  gem.add_dependency 'logger'
  gem.add_dependency 'pdf-reader'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'geminabox'

  gem.files = %w(Rakefile) + Dir.glob("{lib,bin,spec}/**/*")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end

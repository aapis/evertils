lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'evertils/version'

Gem::Specification.new do |s|
  s.name                  = 'evertils'
  s.version               = Evertils::VERSION
  s.date                  = '2017-10-10'
  s.summary               = 'EN (heart) CLI'
  s.description           = 'Evernote utilities for your CLI workflow'
  s.authors               = ['Ryan Priebe']
  s.email                 = 'hello@ryanpriebe.com'
  s.files                 = `git ls-files`.split($\)
  s.homepage              = 'http://rubygems.org/gems/evertils'
  s.license               = 'MIT'
  s.executables           = 'evertils'
  s.required_ruby_version = '>= 2.4.0'

  s.add_runtime_dependency 'evertils-common', '~> 0.3.7'
  s.add_runtime_dependency 'gist', '~> 5.1.0'
  s.add_runtime_dependency 'mime-types', '~> 3.3.1'
  s.add_runtime_dependency 'nokogiri', '~> 1.10.9'
  s.add_runtime_dependency 'notifaction', '~> 0.4.4'

  s.add_development_dependency 'bundler', '~> 1.10'
  s.add_development_dependency 'rake', '~> 12.3.3'
end

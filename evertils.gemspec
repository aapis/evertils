require './lib/version'

Gem::Specification.new do |s|
  s.name          = 'evertils'
  s.version       = Evertils::VERSION
  s.date          = '2015-07-03'
  s.summary       = 'EN (heart) CLI'
  s.description   = 'Evernote utilities for your CLI workflow'
  s.authors       = ['Ryan Priebe']
  s.email         = 'hello@ryanpriebe.com'
  s.files         = `git ls-files`.split($\)
  s.homepage      = 'http://rubygems.org/gems/evertils'
  s.license       = 'MIT'
  s.executables   = 'evertils'

  s.add_runtime_dependency 'evernote-thrift'
  s.add_runtime_dependency 'notifaction'
  s.add_runtime_dependency 'mime-types'
  s.add_runtime_dependency 'evertils-common'
end
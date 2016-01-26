$:.push File.expand_path('../lib', __FILE__)
require 'nfse-webiss/version'

Gem::Specification.new do |gem|
  gem.name        = 'nfse-webiss'
  gem.version     = NfseWebiss::VERSION

  gem.authors     = ['Gabriel Paladino']
  gem.email       = ['gabriel@scupen.com']
  gem.homepage    = 'https://github.com/scupen/nfse-webiss'
  gem.description = 'Gem para emissão de Nota Fiscal de Serviços eletrônica (NFs-e) do sistema WebISS'
  gem.summary     = gem.description
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'savon'
  gem.add_dependency 'signer'
  gem.add_dependency 'haml'
end

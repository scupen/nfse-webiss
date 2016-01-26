require 'haml'

module NfseWebiss
  autoload :Version, 'nfse-webiss/version'
  autoload :Response, 'nfse-webiss/response'

  module Gateways
    autoload :Base, 'nfse-webiss/gateways/base'
    autoload :Webiss, 'nfse-webiss/gateways/webiss'
    autoload :ModernizacaoPublica, 'nfse-webiss/gateways/modernizacao_publica'
  end
end

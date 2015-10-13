# require "nfse-webiss/version"
# require "nfse-webiss/xml_builder"
# require "nfse-webiss/response"
# require "nfse-webiss/gateway"
# require "signer"
# require "savon"

module NfseWebiss
  METHODS = {
    'RecepcionarLoteRps' => 'EnviarLoteRps',
    'ConsultarSituacaoLoteRps' => 'ConsultarSituacaoLoteRps',
    'ConsultarNfsePorRps' => 'ConsultarNfseRps',
    'ConsultarNfse' => 'ConsultarNfse',
    'ConsultarLoteRps' => 'ConsultarLoteRps',
    'CancelarNfse' => 'CancelarNfse'
  }

  autoload :Version, 'nfse-webiss/version'
  autoload :XmlBuilder, 'nfse-webiss/xml_builder'
  autoload :Response, 'nfse-webiss/response'
  autoload :Gateway, 'nfse-webiss/gateway'
end

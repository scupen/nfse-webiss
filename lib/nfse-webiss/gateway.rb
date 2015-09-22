module NfseWebiss
  class Gateway
    def initialize(options = {})
      @ssl_cert = options.delete(:ssl_cert)
      @options = options
    end

    METHODS.keys.each do |method|
      define_method(method.underscore) do |body|
        request(method, body)
      end
    end

    private

    def certificate
      @ssl_cert ||= OpenSSL::PKCS12.new(File.read(@options[:ssl_cert_path]), @options[:ssl_cert_pass])
    end

    def request(method, data = {})
      operation = savon_client.operation('NfseServices', 'BasicHttpBinding_INfseServices', method)
      operation.xml_envelope = XmlBuilder.new.xml_for(method, data, certificate)
      Response.new(method, operation.call)
    rescue Savon::Error
    end

    def savon_client
      @savon ||= Savon.new(@options[:wsdl], http_client)
    end

    def http_client
      client = Savon::HTTPClient.new
      client.client.ssl_config.client_cert = certificate.certificate
      client.client.ssl_config.client_key = certificate.key
      client
    end
  end
end

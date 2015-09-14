module NfseWebiss
  class Gateway

    def initialize(options = {})
      @options = {
        ssl_cert_p12_path: "",
        ssl_cert_path: "", 
        ssl_key_path: "", 
        ssl_cert_pass: "",
        wsdl: ''
      }.merge(options)
    end

    METHODS.keys.each do |method|
      define_method(method.underscore) do |body|
        request(method, body)
      end      
    end

    private

    def certificate
      OpenSSL::PKCS12.new(File.read(@options[:ssl_cert_p12_path]), @options[:ssl_cert_pass])
    end

    def request(method, data = {})
      soap_client = get_client
      operation = soap_client.operation('NfseServices', 'BasicHttpBinding_INfseServices', method)
      operation.xml_envelope = XmlBuilder.new.xml_for(method, data, certificate)
      Response.new(method, operation.call)
      rescue Savon::Error
    end

    def get_client
      http_client = Savon::HTTPClient.new
      http_client.client.ssl_config.set_client_cert_file(@options[:ssl_cert_path], @options[:ssl_key_path], @options[:ssl_cert_pass])
      Savon.new(@options[:wsdl], http_client)
    end

  end
end

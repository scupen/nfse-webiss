module NfseWebiss
  class Response
    
    def initialize(method, savon_response)
      @method = method
      @savon_response = savon_response
      @retorno = nori.parse(savon_response.hash[:envelope][:body]["#{method}Response".snakecase.to_sym]["#{method}Result".snakecase.to_sym])["#{METHODS[method]}Resposta".snakecase.to_sym]
    end

    attr_reader :method, :savon_response, :retorno

    def success?
      !!retorno[:cabecalho][:sucesso]
    end

    def errors
      return unless !success?
      retorno[:alerta] || retorno[:erro]
    end

    private

    def nori
      return @nori if @nori

      nori_options = {
        strip_namespaces: true,
        convert_tags_to: lambda { |tag| tag.snakecase.to_sym }
      }

      @nori = Nori.new(nori_options)
    end

  end
end

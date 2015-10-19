module NfseWebiss
  class Response  
    def initialize(method, savon_response)
      @method = method
      @savon_response = savon_response
      @retorno = parse_response
    end

    attr_reader :method, :savon_response, :retorno

    def sucesso?
      !retorno[:fault] && !retorno[:mensagem_retorno]
    end

    def erros
      return if sucesso?
      retorno[:fault] || retorno[:mensagem_retorno]
    end

    def [](key)
      retorno[key]
    end

    private

    def parse_response
      body = savon_response.hash[:envelope][:body]
      response, result, resposta = %W(#{method}Response #{method}Result #{METHODS[method]}Resposta).map(&:snakecase).map(&:to_sym)
      if body[response]
        parsed = nori.parse(body[response][result].gsub('&', '&amp;'))[resposta] # TODO: arrumar esse gsub
        parsed[:lista_mensagem_retorno] || parsed
      else
        body
      end
    end

    def nori
      return @nori if @nori

      nori_options = {
        strip_namespaces: true,
        convert_tags_to: ->(tag) { tag.snakecase.to_sym }
      }

      @nori = Nori.new(nori_options)
    end
  end
end

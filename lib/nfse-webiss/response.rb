module NfseWebiss
  class Response
    def initialize(method, tag, savon_response)
      @method = method
      @tag = tag
      @savon_response = savon_response
    end

    attr_reader :method, :tag, :savon_response, :xml

    def retorno
      @retorno ||= parse_response
    end

    def [](key)
      retorno[key]
    end

    private

    def parse_response
      body = savon_response.hash[:envelope][:body]
      response, result, resposta = %W(#{method}Response #{method}Return #{tag}Resposta).map(&:snakecase).map(&:to_sym)
      if body[response]
        @xml = body[response][result].gsub('&', '&amp;') # TODO: arrumar esse gsub
        parsed = nori.parse(xml)
        parsed[resposta] || parsed
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

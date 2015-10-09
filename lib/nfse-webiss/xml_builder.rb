module NfseWebiss
  class XmlBuilder
    def xml_for(method, data, certificado)
      # assinar(xml(method, data, certificado), certificado)
      %Q{ 
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns4301="http://tempuri.org">
            <soap:Body>
                <#{method} xmlns="http://tempuri.org/">
                    <cabec></cabec>
                    <msg><![CDATA[#{xml(method, data, certificado)}]]></msg>
                </#{method}>
            </soap:Body>
        </soap:Envelope>
      }.gsub(/>\s+</, "><").gsub(/\n/,'').strip
    end

    private
    
    def xml(method, data, certificado)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.send("#{METHODS[method]}Envio", "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd" => "http://www.w3.org/2001/XMLSchema", "xmlns" => "http://www.abrasf.org.br/nfse" ) {
          send(method.underscore, xml, data, certificado)
        }
      end
      builder.doc.root.to_s
    end

    def identificacao_prestador(xml, data)
      xml.Prestador {
        xml.Cnpj data[:cnpj]
        xml.InscricaoMunicipal data[:inscricao_municipal]
      }
    end

    def identificacao_rps(xml, data)
      xml.IdentificacaoRps {
        xml.Numero data[:numero]
        xml.Serie data[:serie]
        xml.Tipo data[:tipo]
      }
    end

    def recepcionar_lote_rps(xml, data, certificado)
      xml.LoteRps(Id: data[:numero_lote]) {
        xml.NumeroLote data[:numero_lote]
        xml.Cnpj data[:cnpj]
        xml.InscricaoMunicipal data[:inscricao_municipal]
        xml.QuantidadeRps data[:lote_rps].size
        xml.ListaRps {
          data[:lote_rps].each do |rps|
            rps(xml, rps, certificado)
          end
        }
      }
    end

    def rps(xml, data, certificado)
      # data = DEFAULT_DATA.merge(data)
      xml.Rps {
        xml.InfRps(Id: data[:numero]) {
          # xml.Assinatura assinatura_envio_rps(data, certificado)
          # chave_rps_to_xml(xml, data)
          identificacao_rps(xml, data)
          xml.DataEmissao ( data[:data_emissao].is_a?(String) ? data[:data_emissao] : data[:data_emissao].strftime('%FT%T'))
          xml.NaturezaOperacao data[:natureza_operacao]
          xml.RegimeEspecialTributacao data[:regime_especial_tributacao] if data[:regime_especial_tributacao]
          xml.OptanteSimplesNacional data[:optante_simples_nacional]
          xml.IncentivadorCultural data[:incentivador_cultural]
          xml.Status data[:status]
          xml.RpsSubstituido {
            xml.Numero data[:substituido_numero]
            xml.Serie data[:substituido_serie]
            xml.Tipo data[:substituido_tipo]
          } if data[:substituido_numero] && data[:substituido_serie] && data[:substituido_tipo]
          xml.Servico {
            xml.Valores {
              xml.ValorServicos data[:valor_servicos].round(2)
              xml.ValorDeducoes data[:valor_deducoes].round(2) if data[:valor_deducoes]
              xml.ValorPis data[:valor_pis].round(2) if data[:valor_pis]
              xml.ValorCofins data[:valor_cofins].round(2) if data[:valor_cofins]
              xml.ValorInss data[:valor_inss].round(2) if data[:valor_inss]
              xml.ValorIr data[:valor_ir].round(2) if data[:valor_ir]
              xml.ValorCsll data[:valor_csll].round(2) if data[:valor_csll]
              xml.IssRetido data[:iss_retido]
              xml.ValorIss data[:valor_iss].round(2) if data[:valor_iss]
              xml.OutrasRetencoes data[:outras_retencoes].round(2) if data[:outras_retencoes]
              xml.BaseCalculo data[:base_calculo].round(2) if data[:base_calculo]
              xml.Aliquota data[:aliquota] if data[:aliquota]
              xml.ValorLiquidoNfse data[:valor_liquido_nfse].round(2) if data[:valor_liquido_nfse]
              xml.ValorIssRetido data[:valor_iss_retido].round(2) if data[:valor_iss_retido]
              xml.DescontoCondicionado data[:desconto_condicionado].round(2) if data[:desconto_condicionado]
              xml.DescontoIncondicionado data[:desconto_incondicionado].round(2) if data[:desconto_incondicionado]
            }
            xml.ItemListaServico data[:item_lista_servico]
            xml.CodigoCnae data[:codigo_cnae] if data[:codigo_cnae]
            xml.CodigoTributacaoMunicipio data[:codigo_tributacao_municipio] if data[:codigo_tributacao_municipio]
            xml.Discriminacao data[:discriminacao]
            xml.CodigoMunicipio data[:codigo_municipio]
          }
          identificacao_prestador(xml, data)
          xml.Tomador {
            xml.IdentificacaoTomador {
              xml.CpfCnpj {
                xml.send((data[:tomador_cpf_cnpj].length == 14 ? 'Cnpj' : 'Cpf'), data[:tomador_cpf_cnpj])
                xml.InscricaoMunicipal data[:tomador_inscricao_municipal] if data[:tomador_inscricao_municipal]
              }
            }
            xml.RazaoSocial data[:tomador_razao_social]
            xml.Endereco {
              xml.Endereco data[:tomador_endereco]
              xml.Numero data[:tomador_numero]
              xml.Complemento data[:tomador_complemento] if data[:tomador_complemento]
              xml.Bairro data[:tomador_bairro]
              xml.CodigoMunicipio data[:tomador_codigo_municipio]
              xml.Uf data[:tomador_uf]
              xml.Cep data[:tomador_cep]
            }
            xml.Contato {
              xml.Telefone data[:tomador_telefone] if data[:tomador_telefone]
              xml.Email data[:tomador_email] if data[:tomador_email]
            }
          }
        }
      }
    end

    def consultar_situacao_lote_rps(xml, data, certificado)
      # aproveitando os mesmos parametros do outro método (o retorno é diferente)
      consultar_lote_rps(xml, data, certificado)
    end

    def consultar_nfse_por_rps(xml, data, certificado)
      identificacao_rps(xml, data)
      identificacao_prestador(xml, data)
    end

    def consultar_nfse(xml, data, certificado)
      identificacao_prestador(xml, data)
      xml.NumeroNfse data[:numero_nfse]
      xml.PeriodoEmissao {
        xml.DataInicial 'YYYY-MM-DD'
        xml.DataFinal 'YYYY-MM-DD'
      }
      # Tomador
      # IntermediarioServico
    end

    def consultar_lote_rps(xml, data, certificado)
      identificacao_prestador(xml, data)
      xml.Protocolo data[:protocolo]
    end

    def cancelar_nfse(xml, data, certificado)
      xml.Pedido {
        xml.InfPedidoCancelamento {
          xml.IdentificacaoNfse {
            xml.Numero data[:numero_nfse]
            xml.Cnpj data[:cnpj]
            # xml.InscricaoMunicipal
            # xml.CodigoMunicipio
          } 
          # xml.CodigoCancelamento # ?VERIFICAR 
        }
      }
    end

    def assinar(xml, certificado)

      xml = Nokogiri::XML(xml.to_s, &:noblanks)

      # 1. Digest Hash for all XML
      xml_canon = xml.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      xml_digest = Base64.encode64(OpenSSL::Digest::SHA1.digest(xml_canon)).strip

      # 2. Add Signature Node
      signature = xml.xpath("//ds:Signature", "ds" => "http://www.w3.org/2000/09/xmldsig#").first
      unless signature
        signature = Nokogiri::XML::Node.new('Signature', xml)
        signature.default_namespace = 'http://www.w3.org/2000/09/xmldsig#'
        xml.root().add_child(signature)
      end

      # 3. Add Elements to Signature Node
      
      # 3.1 Create Signature Info
      signature_info = Nokogiri::XML::Node.new('SignedInfo', xml)

      # 3.2 Add CanonicalizationMethod
      child_node = Nokogiri::XML::Node.new('CanonicalizationMethod', xml)
      child_node['Algorithm'] = 'http://www.w3.org/2001/10/xml-exc-c14n#'
      signature_info.add_child child_node

      # 3.3 Add SignatureMethod
      child_node = Nokogiri::XML::Node.new('SignatureMethod', xml)
      child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
      signature_info.add_child child_node

      # 3.4 Create Reference
      reference = Nokogiri::XML::Node.new('Reference', xml)
      reference['URI'] = ''

      # 3.5 Add Transforms
      transforms = Nokogiri::XML::Node.new('Transforms', xml)

      child_node  = Nokogiri::XML::Node.new('Transform', xml)
      child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#enveloped-signature'
      transforms.add_child child_node

      child_node  = Nokogiri::XML::Node.new('Transform', xml)
      child_node['Algorithm'] = 'http://www.w3.org/TR/2001/REC-xml-c14n-20010315'
      transforms.add_child child_node

      reference.add_child transforms

      # 3.6 Add Digest
      child_node  = Nokogiri::XML::Node.new('DigestMethod', xml)
      child_node['Algorithm'] = 'http://www.w3.org/2000/09/xmldsig#sha1'
      reference.add_child child_node
      
      # 3.6 Add DigestValue
      child_node  = Nokogiri::XML::Node.new('DigestValue', xml)
      child_node.content = xml_digest
      reference.add_child child_node

      # 3.7 Add Reference and Signature Info
      signature_info.add_child reference
      signature.add_child signature_info

      # 4 Sign Signature
      sign_canon = signature_info.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
      signature_hash = certificado.key.sign(OpenSSL::Digest::SHA1.new, sign_canon)
      signature_value = Base64.encode64( signature_hash ).gsub("\n", '')

      # 4.1 Add SignatureValue
      child_node = Nokogiri::XML::Node.new('SignatureValue', xml)
      child_node.content = signature_value
      signature.add_child child_node

      # 5 Create KeyInfo
      key_info = Nokogiri::XML::Node.new('KeyInfo', xml)
      
      # 5.1 Add X509 Data and Certificate
      x509_data = Nokogiri::XML::Node.new('X509Data', xml)
      x509_certificate = Nokogiri::XML::Node.new('X509Certificate', xml)
      x509_certificate.content = certificado.certificate.to_s.gsub(/\-\-\-\-\-[A-Z]+ CERTIFICATE\-\-\-\-\-/, "").gsub(/\n/,"")

      x509_data.add_child x509_certificate
      key_info.add_child x509_data

      # 5.2 Add KeyInfo
      signature.add_child key_info

      # 6 Add Signature
      xml.root().add_child signature

      # Return XML
      xml.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    end

    def assinatura_cancelamento_n_fe(data, certificado)
      part_1 = data[:inscricao_prestador].rjust(8,'0')
      part_2 = data[:numero_nfe].rjust(12,'0')
      value = part_1 + part_2
      assinatura_simples(value, certificado)
    end
    
    def assinatura_envio_rps(data, certificado)
      part_1 = data[:inscricao_prestador].rjust(8,'0')
      part_2 = data[:serie_rps].ljust(5)
      part_3 = data[:numero_rps].rjust(12,'0')
      part_4 = data[:data_emissao].delete('-')
      part_5 = data[:tributacao_rps]
      part_6 = data[:status_rps]
      part_7 = data[:iss_retido] ? 'S' : 'N'
      part_8 = data[:valor_servicos].delete(',').delete('.').rjust(15,'0')
      part_9 = data[:valor_deducoes].delete(',').delete('.').rjust(15,'0')
      part_10 = data[:codigo_servico].rjust(5,'0')
      part_11 = (data[:cpf_tomador].blank? ? (data[:cnpj_tomador].blank? ? '3' : '2') : '1')
      part_12 = (data[:cpf_tomador].blank? ? (data[:cnpj_tomador].blank? ? "".rjust(14,'0') : data[:cnpj_tomador].rjust(14,'0') ) : data[:cpf_tomador].rjust(14,'0'))

      # part_13 = (data[:cpf_intermediario].blank? ? (data[:cnpj_intermediario].blank? ? '3' : '2') : '1')
      # part_14 = (data[:cpf_intermediario].blank? ? (data[:cnpj_intermediario].blank? ? "".rjust(14,'0') : data[:cnpj_intermediario].rjust(14,'0') ) : data[:cpf_intermediario].rjust(14,'0'))
      # part_15 = data[:iss_retido_intermediario] ? 'S' : 'N'


      #value = part_1 + part_2 + part_3 + part_4 + part_5 + part_6 + part_7 + part_8 + part_9 + part_10 + part_11 + part_12 + part_13 + part_14 + part_15
      value = part_1 + part_2 + part_3 + part_4 + part_5 + part_6 + part_7 + part_8 + part_9 + part_10 + part_11 + part_12

      assinatura_simples(value, certificado)
    end

    def assinatura_simples(value, certificado)
      sign_hash = certificado.key.sign( OpenSSL::Digest::SHA1.new, value )
      Base64.encode64( sign_hash ).gsub("\n",'').gsub("\r",'').strip()
    end
  end
end

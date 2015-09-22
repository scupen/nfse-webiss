# NFs-e WebISS

**Gem para emissão de Nota Fiscal de Serviços eletrônica (NFs-e) do sistema WebISS.**

Essa gem foi baseada na [nfe-paulistana](https://github.com/iugu/nfe-paulistana) e reescrita para funcionar com o WebService do sistema WebISS utilizado por diversas prefeituras no Brasil.

É necessário possuir certificado digital tipo A1 para autenticação com os servidores da prefeitura e assinatura das mensagens.


## Conceito da NFs-e

O sistema WebISS implementa o modelo 1.0 de NFs-e conforme modelo proposto pela [ABRASF](http://www.abrasf.org.br) e documentação abaixo.

- [NFSe_ManualDeIntegracao_2008dez29.pdf](http://www.abrasf.org.br/arquivos/publico/NFS-e/Versao_1.00/NFSe_ManualDeIntegracao_2008dez29.pdf)
- [NFSe_ModeloConceitual_2008dez29.pdf](http://www.abrasf.org.br/arquivos/publico/NFS-e/Versao_1.00/NFSe_ModeloConceitual_2008dez29.pdf)
- [xml_schema_nfse_v1.zip](http://www.abrasf.org.br/arquivos/publico/NFS-e/Versao_1.00/xml_schema_nfse_v1.zip)


## Como usar

### Instanciando o Gateway

As chamadas ao WebService acontece através dos métodos do gateway de conexão que é instanciado com os parâmetros do certificado e url do WSDL da prefeitura em questão.

```ruby

gateway = NfseWebiss::Gateway.new(
	# arquivos .p12 ou .pfx possuem o mesmo funcionamento
	ssl_cert_path: 'path/do/certificado.pfx',
	ssl_cert_pass: 'SENHA',
	# também pode-se passar diretamente o objeto do certificado, se você estiver utilizando ele fora do gateway
	ssl_cert: OpenSSL::PKCS12.new(File.read('path/do/certificado.pfx'), 'SENHA'),
	# url do webservice WebISS da prefeitura em questão e ambiente (produção ou homologação)
	wsdl: 'https://www1.webiss.com.br/rjnovafriburgo_wsnfse_homolog/nfseservices.svc?wsdl'
)

```


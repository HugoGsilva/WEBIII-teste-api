class CepService < ExternalApiService
  BASE_URL = ENV.fetch('CEP_API_URL', 'https://viacep.com.br/ws')

  def fetch_cep(cep)
    sanitized_cep = sanitize_cep(cep)
    url = "#{BASE_URL}/#{sanitized_cep}/json/"
    fetch_with_resilience(url)
  end

  private

  def sanitize_cep(cep)
    cep.to_s.gsub(/\D/, '')
  end

  def fallback_response
    {
      cep: nil,
      logradouro: "Serviço temporariamente indisponível",
      complemento: "",
      bairro: "",
      localidade: "",
      uf: "",
      fallback: true
    }
  end

  def parse_response(response)
    if response.success?
      data = JSON.parse(response.body, symbolize_names: true)
      
      # ViaCEP returns erro: true when CEP is not found
      if data[:erro]
        { success: false, data: fallback_response }
      else
        { success: true, data: data }
      end
    else
      { success: false, data: fallback_response }
    end
  end
end

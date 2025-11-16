module Api
  module V1
    class EnderecosController < BaseController
      def show
        cep = params[:cep]
        
        # Validate CEP format (8 digits, with or without hyphen)
        unless valid_cep_format?(cep)
          return render json: { 
            error: "CEP inválido. Formato esperado: 12345678 ou 12345-678" 
          }, status: :bad_request
        end

        # Call CEP service
        result = CepService.new.fetch_cep(cep)
        
        # Always return 200 with data (even on fallback)
        render json: result[:data], status: :ok
      end

      private

      def valid_cep_format?(cep)
        # CEP should have 8 digits (with or without hyphen)
        cep.to_s.gsub(/\D/, '').length == 8
      end
    end
  end
end

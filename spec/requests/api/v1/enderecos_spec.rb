# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/enderecos', type: :request do
  path '/api/v1/enderecos/{cep}' do
    parameter name: 'cep', in: :path, type: :string, description: 'CEP a ser consultado (com ou sem formatação)',
              schema: {
                type: :string,
                pattern: '^\d{5}-?\d{3}$',
                example: '01310-100'
              }

    get('Consulta endereço por CEP') do
      tags 'Endereços'
      produces 'application/json'
      description 'Consulta informações de endereço através do CEP utilizando a API ViaCEP. ' \
                  'Implementa retry com exponential backoff e retorna fallback em caso de falha.'

      response(200, 'successful - dados do CEP retornados') do
        schema type: :object,
          properties: {
            cep: { type: :string, example: '01310-100' },
            logradouro: { type: :string, example: 'Avenida Paulista' },
            complemento: { type: :string, example: 'lado ímpar' },
            bairro: { type: :string, example: 'Bela Vista' },
            localidade: { type: :string, example: 'São Paulo' },
            uf: { type: :string, example: 'SP' },
            ibge: { type: :string, example: '3550308' },
            gia: { type: :string, example: '1004' },
            ddd: { type: :string, example: '11' },
            siafi: { type: :string, example: '7107' }
          },
          required: ['cep', 'logradouro', 'bairro', 'localidade', 'uf']

        let(:cep) { '01310-100' }

        before do
          stub_request(:get, 'https://viacep.com.br/ws/01310100/json/')
            .to_return(
              status: 200,
              body: {
                cep: '01310-100',
                logradouro: 'Avenida Paulista',
                complemento: 'lado ímpar',
                bairro: 'Bela Vista',
                localidade: 'São Paulo',
                uf: 'SP',
                ibge: '3550308',
                gia: '1004',
                ddd: '11',
                siafi: '7107'
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['cep']).to eq('01310-100')
          expect(data['logradouro']).to eq('Avenida Paulista')
          expect(data['localidade']).to eq('São Paulo')
        end
      end

      response(200, 'successful - fallback response (API externa indisponível)') do
        schema type: :object,
          properties: {
            cep: { type: :string, example: '01310-100' },
            logradouro: { type: :string, example: 'Serviço temporariamente indisponível' },
            fallback: { type: :boolean, example: true }
          },
          required: ['cep', 'logradouro', 'fallback']

        let(:cep) { '01310-100' }

        before do
          stub_request(:get, 'https://viacep.com.br/ws/01310100/json/')
            .to_timeout
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['fallback']).to be true
          expect(data['logradouro']).to include('indisponível')
        end
      end

      response(200, 'successful - CEP formatado com hífen') do
        schema type: :object,
          properties: {
            cep: { type: :string },
            logradouro: { type: :string },
            bairro: { type: :string },
            localidade: { type: :string },
            uf: { type: :string }
          }

        let(:cep) { '20040-020' }

        before do
          stub_request(:get, 'https://viacep.com.br/ws/20040020/json/')
            .to_return(
              status: 200,
              body: {
                cep: '20040-020',
                logradouro: 'Avenida Rio Branco',
                bairro: 'Centro',
                localidade: 'Rio de Janeiro',
                uf: 'RJ'
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['cep']).to eq('20040-020')
          expect(data['localidade']).to eq('Rio de Janeiro')
        end
      end

      response(200, 'successful - CEP sem formatação') do
        schema type: :object,
          properties: {
            cep: { type: :string },
            logradouro: { type: :string },
            bairro: { type: :string },
            localidade: { type: :string },
            uf: { type: :string }
          }

        let(:cep) { '30130100' }

        before do
          stub_request(:get, 'https://viacep.com.br/ws/30130100/json/')
            .to_return(
              status: 200,
              body: {
                cep: '30130-100',
                logradouro: 'Avenida Afonso Pena',
                bairro: 'Centro',
                localidade: 'Belo Horizonte',
                uf: 'MG'
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['localidade']).to eq('Belo Horizonte')
        end
      end

      response(200, 'successful - retry com exponential backoff após falhas temporárias') do
        schema type: :object,
          properties: {
            cep: { type: :string },
            logradouro: { type: :string }
          }

        let(:cep) { '01310-100' }

        before do
          # Simula 2 falhas seguidas de sucesso (testa retry logic)
          stub_request(:get, 'https://viacep.com.br/ws/01310100/json/')
            .to_timeout.times(2).then
            .to_return(
              status: 200,
              body: {
                cep: '01310-100',
                logradouro: 'Avenida Paulista',
                bairro: 'Bela Vista',
                localidade: 'São Paulo',
                uf: 'SP'
              }.to_json,
              headers: { 'Content-Type' => 'application/json' }
            )
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['logradouro']).to eq('Avenida Paulista')
        end
      end
    end
  end
end

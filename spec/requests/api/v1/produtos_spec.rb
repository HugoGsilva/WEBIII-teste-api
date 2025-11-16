# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/produtos', type: :request do
  path '/api/v1/produtos' do
    get('Lista todos os produtos') do
      tags 'Produtos'
      produces 'application/json'
      description 'Retorna a lista completa de produtos cadastrados no sistema'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { '$ref' => '#/components/schemas/produto' }
            }
          }

        let!(:produtos) { create_list(:produto, 3) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data'].length).to eq(3)
        end
      end
    end

    post('Cria um novo produto') do
      tags 'Produtos'
      consumes 'application/json'
      produces 'application/json'
      description 'Cria um novo produto no sistema'

      parameter name: :produto, in: :body, schema: {
        type: :object,
        properties: {
          produto: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Notebook Dell' },
              description: { type: :string, example: 'Notebook de alta performance' },
              price: { type: :number, example: 2999.99 },
              stock_quantity: { type: :integer, example: 10 }
            },
            required: ['name', 'price', 'stock_quantity']
          }
        }
      }

      response(201, 'created') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/produto' }
          }

        let(:produto) do
          {
            produto: {
              name: 'Notebook Dell',
              description: 'Notebook de alta performance',
              price: 2999.99,
              stock_quantity: 10
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['name']).to eq('Notebook Dell')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/validation_errors'

        let(:produto) do
          {
            produto: {
              name: '',
              price: -10,
              stock_quantity: -5
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end
  end

  path '/api/v1/produtos/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'ID do produto'

    get('Retorna um produto específico') do
      tags 'Produtos'
      produces 'application/json'
      description 'Retorna os detalhes de um produto específico pelo ID'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/produto' }
          }

        let!(:produto_record) { create(:produto, name: 'Mouse Logitech') }
        let(:id) { produto_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['name']).to eq('Mouse Logitech')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { 'invalid' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end
    end

    patch('Atualiza um produto') do
      tags 'Produtos'
      consumes 'application/json'
      produces 'application/json'
      description 'Atualiza as informações de um produto existente'

      parameter name: :produto, in: :body, schema: {
        type: :object,
        properties: {
          produto: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :number },
              stock_quantity: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/produto' }
          }

        let!(:produto_record) { create(:produto, name: 'Teclado Mecânico') }
        let(:id) { produto_record.id }
        let(:produto) do
          {
            produto: {
              name: 'Teclado Mecânico RGB',
              price: 450.00
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['name']).to eq('Teclado Mecânico RGB')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { 'invalid' }
        let(:produto) { { produto: { name: 'Updated Name' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/validation_errors'

        let!(:produto_record) { create(:produto) }
        let(:id) { produto_record.id }
        let(:produto) do
          {
            produto: {
              price: -100
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end

    put('Atualiza um produto') do
      tags 'Produtos'
      consumes 'application/json'
      produces 'application/json'
      description 'Atualiza as informações de um produto existente'

      parameter name: :produto, in: :body, schema: {
        type: :object,
        properties: {
          produto: {
            type: :object,
            properties: {
              name: { type: :string },
              description: { type: :string },
              price: { type: :number },
              stock_quantity: { type: :integer }
            }
          }
        }
      }

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/produto' }
          }

        let!(:produto_record) { create(:produto) }
        let(:id) { produto_record.id }
        let(:produto) do
          {
            produto: {
              name: 'Updated Product',
              price: 99.99,
              stock_quantity: 5
            }
          }
        end

        run_test!
      end
    end

    delete('Remove um produto') do
      tags 'Produtos'
      produces 'application/json'
      description 'Remove um produto do sistema'

      response(204, 'no content') do
        let!(:produto_record) { create(:produto) }
        let(:id) { produto_record.id }

        run_test!
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { 'invalid' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end
    end
  end
end

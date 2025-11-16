# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/pedidos', type: :request do
  path '/api/v1/pedidos' do
    get('Lista todos os pedidos') do
      tags 'Pedidos'
      produces 'application/json'
      description 'Retorna a lista completa de pedidos com seus itens'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { '$ref' => '#/components/schemas/pedido' }
            },
            included: {
              type: :array,
              items: { '$ref' => '#/components/schemas/item' }
            }
          }

        let!(:produto) { create(:produto) }
        let!(:pedido1) { create(:pedido) }
        let!(:item1) { create(:item, pedido: pedido1, produto: produto) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']).to be_an(Array)
        end
      end
    end

    post('Cria um novo pedido') do
      tags 'Pedidos'
      consumes 'application/json'
      produces 'application/json'
      description 'Cria um novo pedido com itens associados usando nested attributes'

      parameter name: :pedido, in: :body, schema: {
        type: :object,
        properties: {
          pedido: {
            type: :object,
            properties: {
              customer_name: { type: :string, example: 'João Silva' },
              status: { type: :string, example: 'pending', enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'] },
              itens_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    produto_id: { type: :integer, example: 1 },
                    quantity: { type: :integer, example: 2 },
                    unit_price: { type: :number, example: 99.99 }
                  },
                  required: ['produto_id', 'quantity', 'unit_price']
                }
              }
            },
            required: ['customer_name', 'status', 'itens_attributes']
          }
        }
      }

      response(201, 'created') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/pedido' },
            included: {
              type: :array,
              items: { '$ref' => '#/components/schemas/item' }
            }
          }

        let!(:produto) { create(:produto, price: 99.99) }
        let(:pedido) do
          {
            pedido: {
              customer_name: 'João Silva',
              status: 'pending',
              itens_attributes: [
                {
                  produto_id: produto.id,
                  quantity: 2,
                  unit_price: 99.99
                }
              ]
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['customer_name']).to eq('João Silva')
          expect(data['data']['attributes']['total_amount']).to eq('199.98')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/validation_errors'

        let(:pedido) do
          {
            pedido: {
              customer_name: '',
              status: 'invalid_status',
              itens_attributes: []
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

  path '/api/v1/pedidos/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'ID do pedido'

    get('Retorna um pedido específico') do
      tags 'Pedidos'
      produces 'application/json'
      description 'Retorna os detalhes de um pedido específico com seus itens'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/pedido' },
            included: {
              type: :array,
              items: { '$ref' => '#/components/schemas/item' }
            }
          }

        let!(:produto) { create(:produto) }
        let!(:pedido_record) { create(:pedido, customer_name: 'Maria Santos') }
        let!(:item) { create(:item, pedido: pedido_record, produto: produto) }
        let(:id) { pedido_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['customer_name']).to eq('Maria Santos')
          expect(data['included']).to be_an(Array)
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

    patch('Atualiza um pedido') do
      tags 'Pedidos'
      consumes 'application/json'
      produces 'application/json'
      description 'Atualiza as informações de um pedido existente, incluindo seus itens'

      parameter name: :pedido, in: :body, schema: {
        type: :object,
        properties: {
          pedido: {
            type: :object,
            properties: {
              customer_name: { type: :string },
              status: { type: :string, enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'] },
              itens_attributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    produto_id: { type: :integer },
                    quantity: { type: :integer },
                    unit_price: { type: :number },
                    _destroy: { type: :boolean }
                  }
                }
              }
            }
          }
        }
      }

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/pedido' },
            included: {
              type: :array,
              items: { '$ref' => '#/components/schemas/item' }
            }
          }

        let!(:produto) { create(:produto) }
        let!(:pedido_record) { create(:pedido, customer_name: 'Carlos Oliveira', status: 'pending') }
        let!(:item) { create(:item, pedido: pedido_record, produto: produto) }
        let(:id) { pedido_record.id }
        let(:pedido) do
          {
            pedido: {
              status: 'confirmed'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['attributes']['status']).to eq('confirmed')
        end
      end

      response(404, 'not found') do
        schema '$ref' => '#/components/schemas/error'

        let(:id) { 'invalid' }
        let(:pedido) { { pedido: { status: 'confirmed' } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('error')
        end
      end

      response(422, 'unprocessable entity') do
        schema '$ref' => '#/components/schemas/validation_errors'

        let!(:pedido_record) { create(:pedido) }
        let(:id) { pedido_record.id }
        let(:pedido) do
          {
            pedido: {
              status: 'invalid_status'
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('errors')
        end
      end
    end

    put('Atualiza um pedido') do
      tags 'Pedidos'
      consumes 'application/json'
      produces 'application/json'
      description 'Atualiza as informações de um pedido existente'

      parameter name: :pedido, in: :body, schema: {
        type: :object,
        properties: {
          pedido: {
            type: :object,
            properties: {
              customer_name: { type: :string },
              status: { type: :string },
              itens_attributes: { type: :array }
            }
          }
        }
      }

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/pedido' }
          }

        let!(:produto) { create(:produto) }
        let!(:pedido_record) { create(:pedido) }
        let!(:item) { create(:item, pedido: pedido_record, produto: produto) }
        let(:id) { pedido_record.id }
        let(:pedido) do
          {
            pedido: {
              customer_name: 'Updated Customer',
              status: 'shipped'
            }
          }
        end

        run_test!
      end
    end

    delete('Remove um pedido') do
      tags 'Pedidos'
      produces 'application/json'
      description 'Remove um pedido e seus itens do sistema'

      response(204, 'no content') do
        let!(:produto) { create(:produto) }
        let!(:pedido_record) { create(:pedido) }
        let!(:item) { create(:item, pedido: pedido_record, produto: produto) }
        let(:id) { pedido_record.id }

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

# frozen_string_literal: true

require 'rails_helper'

# To generate the swagger.yaml file, run:
# docker-compose exec web rake rswag:specs:swaggerize
# or locally: bundle exec rake rswag:specs:swaggerize
#
# The generated file will be available at swagger/v1/swagger.yaml
# and accessible via the Swagger UI at http://localhost:3000/api-docs

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as the files are written to the swagger_root
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Minha Loja API V1',
        version: 'v1',
        description: 'API RESTful para gerenciamento de produtos e pedidos com integração externa de CEP'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        schemas: {
          produto: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  description: { type: :string, nullable: true },
                  price: { type: :string },
                  stock_quantity: { type: :integer }
                },
                required: ['name', 'price', 'stock_quantity']
              }
            },
            required: ['id', 'type', 'attributes']
          },
          pedido: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string },
              attributes: {
                type: :object,
                properties: {
                  customer_name: { type: :string },
                  total_amount: { type: :string },
                  status: { type: :string }
                },
                required: ['customer_name', 'total_amount', 'status']
              },
              relationships: {
                type: :object,
                properties: {
                  itens: {
                    type: :object,
                    properties: {
                      data: {
                        type: :array,
                        items: {
                          type: :object,
                          properties: {
                            id: { type: :string },
                            type: { type: :string }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            required: ['id', 'type', 'attributes']
          },
          item: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string },
              attributes: {
                type: :object,
                properties: {
                  quantity: { type: :integer },
                  unit_price: { type: :string }
                },
                required: ['quantity', 'unit_price']
              }
            },
            required: ['id', 'type', 'attributes']
          },
          error: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          },
          validation_errors: {
            type: :object,
            properties: {
              errors: { type: :object }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end

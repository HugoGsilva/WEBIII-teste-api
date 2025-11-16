# Swagger Documentation

This directory contains the generated OpenAPI/Swagger documentation for the Minha Loja API.

## Generating Documentation

To generate the swagger.yaml file from the rswag specs, run:

### Using Docker:
```bash
docker-compose exec web rake rswag:specs:swaggerize
```

### Without Docker:
```bash
bundle exec rake rswag:specs:swaggerize
```

## Accessing Documentation

Once the swagger.yaml file is generated, you can access the interactive API documentation at:

**http://localhost:3000/api-docs**

## Documentation Structure

The documentation is generated from the following spec files:
- `spec/requests/api/v1/produtos_spec.rb` - Produtos endpoints
- `spec/requests/api/v1/pedidos_spec.rb` - Pedidos endpoints
- `spec/requests/api/v1/enderecos_spec.rb` - CEP integration endpoint

## Updating Documentation

Whenever you modify the API endpoints or add new ones:
1. Update the corresponding spec file with rswag annotations
2. Run the swaggerize rake task to regenerate the documentation
3. Refresh the browser to see the updated documentation

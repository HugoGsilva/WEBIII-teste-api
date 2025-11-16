# Requirements Document

## Introduction

Este documento define os requisitos para o microservice **minha_loja_api**, uma API RESTful construída em Rails (modo API-only) que gerencia produtos e pedidos, além de integrar-se com APIs externas de forma robusta. O sistema deve seguir boas práticas de design de API, incluindo versionamento, serialização controlada e tratamento resiliente de falhas em integrações externas. O sistema deve ser containerizado usando Docker para facilitar o desenvolvimento, testes e deployment.

## Glossary

- **Sistema**: O microservice minha_loja_api
- **API Externa**: Serviço público de terceiros (ex: API de CEP ou cotação de câmbio)
- **Cliente**: Aplicação ou usuário que consome os endpoints do Sistema
- **Endpoint**: Rota HTTP exposta pelo Sistema
- **Serializer**: Componente que formata a resposta JSON
- **Timeout**: Limite de tempo para aguardar resposta de uma requisição
- **Retry**: Nova tentativa automática de requisição após falha
- **Backoff**: Aumento progressivo do tempo de espera entre retries
- **Fallback**: Resposta padrão retornada quando a API Externa falha
- **Container**: Ambiente isolado que empacota a aplicação e suas dependências
- **Docker**: Plataforma de containerização usada para empacotar o Sistema
- **Docker Compose**: Ferramenta para definir e executar aplicações multi-container
- **Image**: Template imutável usado para criar containers
- **Volume**: Mecanismo de persistência de dados em containers

## Requirements

### Requirement 1

**User Story:** Como desenvolvedor, eu quero criar um projeto Rails em modo API-only, para que o sistema seja otimizado para servir apenas dados JSON sem overhead de views.

#### Acceptance Criteria

1. THE Sistema SHALL be configured as a Rails API-only application
2. THE Sistema SHALL exclude middleware and gems related to HTML rendering
3. THE Sistema SHALL include only API-specific dependencies in the Gemfile

### Requirement 2

**User Story:** Como desenvolvedor de frontend, eu quero que todos os endpoints estejam versionados sob /api/v1, para que futuras mudanças não quebrem minha integração atual.

#### Acceptance Criteria

1. THE Sistema SHALL expose all endpoints under the namespace "/api/v1"
2. THE Sistema SHALL use route-based versioning strategy
3. THE Sistema SHALL maintain consistent URL structure across all endpoints

### Requirement 3

**User Story:** Como administrador da loja, eu quero gerenciar produtos através de uma API, para que eu possa criar, visualizar, atualizar e remover produtos do catálogo.

#### Acceptance Criteria

1. THE Sistema SHALL provide a Produto model with attributes: name, description, price, and stock_quantity
2. THE Sistema SHALL expose a POST endpoint at "/api/v1/produtos" to create new products
3. THE Sistema SHALL expose a GET endpoint at "/api/v1/produtos" to list all products
4. THE Sistema SHALL expose a GET endpoint at "/api/v1/produtos/:id" to retrieve a specific product
5. THE Sistema SHALL expose a PATCH endpoint at "/api/v1/produtos/:id" to update product information
6. THE Sistema SHALL expose a DELETE endpoint at "/api/v1/produtos/:id" to remove a product

### Requirement 4

**User Story:** Como administrador da loja, eu quero gerenciar pedidos através de uma API, para que eu possa criar, visualizar, atualizar e remover pedidos com seus itens.

#### Acceptance Criteria

1. THE Sistema SHALL provide a Pedido model with attributes: customer_name, total_amount, and status
2. THE Sistema SHALL provide an Item model with attributes: produto_id, quantity, and unit_price
3. WHEN creating a Pedido, THE Sistema SHALL support a has_many relationship with Item
4. THE Sistema SHALL expose a POST endpoint at "/api/v1/pedidos" to create new orders with items
5. THE Sistema SHALL expose a GET endpoint at "/api/v1/pedidos" to list all orders
6. THE Sistema SHALL expose a GET endpoint at "/api/v1/pedidos/:id" to retrieve a specific order with its items
7. THE Sistema SHALL expose a PATCH endpoint at "/api/v1/pedidos/:id" to update order information
8. THE Sistema SHALL expose a DELETE endpoint at "/api/v1/pedidos/:id" to remove an order

### Requirement 5

**User Story:** Como desenvolvedor de frontend, eu quero receber respostas JSON bem formatadas e consistentes, para que eu possa processar os dados facilmente em minha aplicação.

#### Acceptance Criteria

1. THE Sistema SHALL use jsonapi-serializer or fast_jsonapi for all JSON responses
2. THE Sistema SHALL format responses following JSON:API specification
3. THE Sistema SHALL expose only necessary attributes in serialized responses
4. THE Sistema SHALL exclude sensitive or internal fields from API responses
5. THE Sistema SHALL include relationship data in serialized responses when applicable

### Requirement 6

**User Story:** Como desenvolvedor, eu quero integrar uma API externa de forma robusta, para que meu sistema não falhe quando o serviço externo estiver lento ou indisponível.

#### Acceptance Criteria

1. THE Sistema SHALL use Faraday library to consume external APIs
2. THE Sistema SHALL configure open_timeout with a maximum value of 5 seconds
3. THE Sistema SHALL configure read_timeout with a maximum value of 10 seconds
4. THE Sistema SHALL implement automatic retry mechanism with a maximum of 3 attempts
5. THE Sistema SHALL implement exponential backoff between retry attempts
6. WHEN the API Externa fails after all retries, THE Sistema SHALL return a fallback response to the Cliente
7. THE Sistema SHALL log all failed attempts to the API Externa
8. THE Sistema SHALL return HTTP status 200 with fallback data instead of HTTP status 500 when API Externa is unavailable

### Requirement 7

**User Story:** Como desenvolvedor, eu quero consumir uma API pública (CEP ou cotação de câmbio), para que meu sistema possa enriquecer dados de pedidos ou produtos com informações externas.

#### Acceptance Criteria

1. THE Sistema SHALL expose at least one endpoint that integrates with an API Externa
2. WHERE CEP integration is chosen, THE Sistema SHALL provide an endpoint at "/api/v1/enderecos/:cep" to retrieve address information
3. WHERE currency exchange integration is chosen, THE Sistema SHALL provide an endpoint at "/api/v1/cambio/:moeda" to retrieve exchange rates
4. THE Sistema SHALL validate input parameters before calling the API Externa
5. THE Sistema SHALL transform API Externa responses into a consistent format

### Requirement 8

**User Story:** Como desenvolvedor de frontend, eu quero documentação OpenAPI (Swagger) dos endpoints, para que eu possa entender como usar a API sem ler o código fonte.

#### Acceptance Criteria

1. THE Sistema SHALL provide OpenAPI documentation for all endpoints
2. THE Sistema SHALL document request parameters, headers, and body schemas
3. THE Sistema SHALL document response schemas and status codes
4. THE Sistema SHALL document the external API integration endpoint with examples
5. THE Sistema SHALL make the documentation accessible through a web interface

### Requirement 9

**User Story:** Como desenvolvedor, eu quero validações adequadas nos modelos, para que dados inválidos não sejam persistidos no banco de dados.

#### Acceptance Criteria

1. THE Sistema SHALL validate presence of required fields in Produto model
2. THE Sistema SHALL validate that price in Produto model is a positive number
3. THE Sistema SHALL validate that stock_quantity in Produto model is a non-negative integer
4. THE Sistema SHALL validate presence of required fields in Pedido model
5. THE Sistema SHALL validate that total_amount in Pedido model is a positive number
6. THE Sistema SHALL validate that each Item has a valid produto_id reference
7. WHEN validation fails, THE Sistema SHALL return HTTP status 422 with error details

### Requirement 10

**User Story:** Como desenvolvedor, eu quero containerizar a aplicação com Docker, para que o ambiente de desenvolvimento seja consistente e o deployment seja simplificado.

#### Acceptance Criteria

1. THE Sistema SHALL provide a Dockerfile to build the application image
2. THE Sistema SHALL provide a docker-compose.yml file to orchestrate application and database containers
3. THE Sistema SHALL configure PostgreSQL database as a separate container
4. THE Sistema SHALL use Docker volumes to persist database data
5. THE Sistema SHALL expose the application on port 3000 from the container
6. THE Sistema SHALL include environment variables configuration for containerized environment
7. WHEN running docker-compose up, THE Sistema SHALL start both application and database containers
8. THE Sistema SHALL support running database migrations inside the container
9. THE Sistema SHALL configure proper networking between application and database containers

### Requirement 11

**User Story:** Como desenvolvedor, eu quero um README claro e completo, para que outros desenvolvedores possam configurar e executar o projeto facilmente com ou sem Docker.

#### Acceptance Criteria

1. THE Sistema SHALL include a README.md file in the repository root
2. THE Sistema SHALL document all available endpoints with HTTP methods and paths
3. THE Sistema SHALL provide step-by-step instructions to run the project locally with Docker
4. THE Sistema SHALL provide step-by-step instructions to run the project locally without Docker
5. THE Sistema SHALL document required dependencies and versions
6. THE Sistema SHALL document database setup and migration commands for both Docker and non-Docker environments
7. THE Sistema SHALL document authentication requirements if applicable
8. THE Sistema SHALL include examples of API requests and responses
9. THE Sistema SHALL document Docker commands for building, running, and stopping containers

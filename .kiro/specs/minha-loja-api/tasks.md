# Implementation Plan

  - [x] 1. Set up Docker containerization infrastructure


  - [x] 1.1 Create initial Dockerfile for Rails development


    - Create Dockerfile in project root
    - Use ruby:3.2 as base image (simpler for development, can optimize later)
    - Install system dependencies (build-essential, libpq-dev, nodejs, yarn)
    - Set working directory to /app
    - Copy Gemfile and Gemfile.lock (will be created in next step)
    - Expose port 3000
    - Set CMD to start Rails server bound to 0.0.0.0
    - _Requirements: 10.1_
  
  - [x] 1.2 Create docker-compose.yml for development environment


    - Create docker-compose.yml in project root
    - Define db service using postgres:15-alpine image
    - Configure PostgreSQL environment variables (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB)
    - Add postgres_data volume for database persistence
    - Add healthcheck for database service
    - Define web service that builds from Dockerfile
    - Configure web service command to start bash (interactive mode for initial setup)
    - Mount source code as volume for live reloading
    - Add bundle_cache volume for faster gem installation
    - Expose port 3000 from web service
    - Set DATABASE_URL environment variable pointing to db service
    - Configure web service to depend on healthy db service
    - _Requirements: 10.2, 10.3, 10.4, 10.5, 10.7, 10.9_
  
  - [x] 1.3 Create .dockerignore file


    - Create .dockerignore in project root
    - Exclude .git directory
    - Exclude tmp and log directories
    - Exclude node_modules if present
    - Exclude test and spec directories
    - Exclude .env files
    - _Requirements: 10.1_

- [x] 2. Initialize Rails API project inside Docker container




  - [x] 2.1 Create Rails application using Docker


    - Start Docker containers with docker-compose up
    - Execute rails new command inside web container: `docker-compose run web rails new . --api --database=postgresql --skip-git --force`
    - This creates the Rails app structure inside the mounted volume
    - _Requirements: 1.1, 1.2_
  
  - [x] 2.2 Configure Gemfile with required dependencies


    - Add jsonapi-serializer gem for JSON serialization
    - Add faraday gem for external API integration
    - Add rswag gems (rswag-api, rswag-ui) for OpenAPI documentation
    - Add rspec-rails, factory_bot_rails, webmock, shoulda-matchers to test group
    - Run bundle install inside container: `docker-compose run web bundle install`
    - _Requirements: 1.3_
  
  - [x] 2.3 Configure database.yml for Docker environment


    - Update config/database.yml to use DATABASE_URL environment variable
    - Ensure database host points to 'db' service in Docker environment
    - Configure connection pool settings appropriate for containerized environment
    - _Requirements: 10.3, 10.9_
  
  - [x] 2.4 Initialize RSpec and configure testing environment


    - Run RSpec installer inside container: `docker-compose run web rails generate rspec:install`
    - Configure RSpec with FactoryBot, WebMock, and Shoulda Matchers in spec/rails_helper.rb
    - _Requirements: 1.3_
  
  - [x] 2.5 Update docker-compose.yml command for development


    - Change web service command from bash to: `bash -c "rm -f tmp/pids/server.pid && bundle exec rails db:prepare && bundle exec rails server -b 0.0.0.0"`
    - This ensures automatic database setup and server start
    - _Requirements: 10.7, 10.8_
  
  - [x] 2.6 Test Docker setup










    - Rebuild containers with docker-compose up --build
    - Verify database migrations run automatically
    - Test that Rails welcome page is accessible on localhost:3000
    - Verify database persistence by stopping and restarting containers
    - Test running Rails console in container: `docker-compose exec web rails console`
    - _Requirements: 10.2, 10.7, 10.8_

- [x] 3. Set up API versioning and routing structure





  - Create namespace structure in routes.rb for /api/v1
  - Create base controller at app/controllers/api/v1/base_controller.rb with error handling
  - Add rescue_from handlers for ActiveRecord::RecordNotFound and ActiveRecord::RecordInvalid
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 4. Implement Produto model and CRUD endpoints




  - [x] 4.1 Create Produto model with migrations


    - Generate migration for produtos table with columns: name (string), description (text), price (decimal), stock_quantity (integer)
    - Add validations: presence of name, price > 0, stock_quantity >= 0
    - Add index on name column
    - Run migration
    - _Requirements: 3.1, 9.1, 9.2, 9.3_
  
  - [x] 4.2 Create ProdutoSerializer


    - Generate serializer using jsonapi-serializer
    - Include attributes: name, description, price, stock_quantity
    - Exclude timestamps from serialization
    - _Requirements: 5.1, 5.2, 5.3, 5.4_
  
  - [x] 4.3 Implement ProdutosController with all CRUD actions


    - Create controller at app/controllers/api/v1/produtos_controller.rb
    - Implement index action (GET /api/v1/produtos) returning all products
    - Implement show action (GET /api/v1/produtos/:id) returning single product
    - Implement create action (POST /api/v1/produtos) with strong parameters
    - Implement update action (PATCH /api/v1/produtos/:id)
    - Implement destroy action (DELETE /api/v1/produtos/:id)
    - Use ProdutoSerializer for all responses
    - Return appropriate HTTP status codes (200, 201, 404, 422)
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 9.7_
  
  - [ ]* 4.4 Write tests for Produto model and controller
    - Create model specs testing validations and associations
    - Create request specs for all CRUD endpoints
    - Test successful and error scenarios
    - Use FactoryBot for test data
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 5. Implement Pedido and Item models with relationships







  - [x] 5.1 Create Item model with migrations

    - Generate migration for itens table with columns: pedido_id (bigint), produto_id (bigint), quantity (integer), unit_price (decimal)
    - Add foreign key constraints and indexes
    - Add validations: presence of produto_id, quantity > 0, unit_price > 0
    - Add belongs_to associations for pedido and produto
    - _Requirements: 4.2, 9.6_
  

  - [x] 5.2 Create Pedido model with migrations

    - Generate migration for pedidos table with columns: customer_name (string), total_amount (decimal), status (string)
    - Add has_many :itens association with dependent: :destroy
    - Add accepts_nested_attributes_for :itens
    - Add validations: presence of customer_name, total_amount > 0, status inclusion
    - Implement before_validation callback to calculate total_amount from items
    - Run migrations
    - _Requirements: 4.1, 4.3, 9.4, 9.5_
  


  - [x] 5.3 Create ItemSerializer and PedidoSerializer

    - Create ItemSerializer with attributes: quantity, unit_price
    - Create PedidoSerializer with attributes: customer_name, total_amount, status
    - Add has_many :itens relationship in PedidoSerializer
    - Configure serializer to include items in response
    - _Requirements: 5.1, 5.2, 5.5_

  
  - [x] 5.4 Implement PedidosController with CRUD and nested items support

    - Create controller at app/controllers/api/v1/pedidos_controller.rb
    - Implement index action (GET /api/v1/pedidos) with eager loading of items
    - Implement show action (GET /api/v1/pedidos/:id) including items
    - Implement create action (POST /api/v1/pedidos) accepting nested items_attributes
    - Implement update action (PATCH /api/v1/pedidos/:id)
    - Implement destroy action (DELETE /api/v1/pedidos/:id)
    - Use strong parameters to permit nested attributes
    - Use PedidoSerializer for all responses
    - _Requirements: 4.4, 4.5, 4.6, 4.7, 4.8_
  
  - [ ]* 5.5 Write tests for Pedido, Item models and controller
    - Create model specs for Pedido testing validations, associations, and total_amount calculation
    - Create model specs for Item testing validations and associations
    - Create request specs for all Pedidos CRUD endpoints
    - Test nested attributes creation and updates
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

- [x] 6. Implement external API integration service with resilience patterns






  - [x] 6.1 Create base ExternalApiService class

    - Create service at app/services/external_api_service.rb
    - Initialize Faraday connection with open_timeout: 5 and read_timeout: 10
    - Implement fetch_with_resilience method with retry logic
    - Implement exponential backoff calculation (2^attempt seconds)
    - Add error logging for failed attempts
    - Define abstract fallback_response method
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.7_
  

  - [x] 6.2 Implement CEP integration service

    - Create CepService class inheriting from ExternalApiService
    - Define BASE_URL for ViaCEP API (https://viacep.com.br/ws)
    - Implement fetch_cep method that calls fetch_with_resilience
    - Implement sanitize_cep method to remove non-digit characters
    - Implement fallback_response returning friendly message
    - Parse successful responses into consistent format
    - _Requirements: 6.6, 6.8, 7.1, 7.2, 7.4, 7.5_
  
  - [x] 6.3 Create EnderecosController for CEP endpoint


    - Create controller at app/controllers/api/v1/enderecos_controller.rb
    - Implement show action (GET /api/v1/enderecos/:cep)
    - Validate CEP format before calling service
    - Call CepService.fetch_cep with sanitized CEP
    - Return formatted response with status 200 (even on fallback)
    - Handle both success and fallback scenarios gracefully
    - _Requirements: 7.2, 7.4, 7.5, 6.6, 6.8_
  
  - [ ]* 6.4 Write tests for external API integration
    - Create service specs for ExternalApiService testing retry logic and backoff
    - Create service specs for CepService with WebMock stubs
    - Test successful API response scenario
    - Test timeout scenario with fallback
    - Test connection failure with retries
    - Create request specs for EnderecosController
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 6.8_
-

- [x] 7. Set up OpenAPI documentation with rswag








  - [x] 7.1 Configure rswag for API documentation


    - Add rswag-api, rswag-ui gems to Gemfile
    - Run rswag:install generator
    - Configure swagger_helper.rb with API info and servers
    - Mount rswag-ui engine in routes.rb at /api-docs
    - _Requirements: 8.1, 8.5_
  
  - [x] 7.2 Document Produtos endpoints


    - Create spec/requests/api/v1/produtos_spec.rb with rswag annotations
    - Document GET /api/v1/produtos with response schema
    - Document GET /api/v1/produtos/:id with parameters and responses
    - Document POST /api/v1/produtos with request body schema
    - Document PATCH /api/v1/produtos/:id
    - Document DELETE /api/v1/produtos/:id
    - Include example responses for success and error cases
    - _Requirements: 8.1, 8.2, 8.3_
  
  - [x] 7.3 Document Pedidos endpoints


    - Create spec/requests/api/v1/pedidos_spec.rb with rswag annotations
    - Document all CRUD endpoints with nested items structure
    - Include schemas for request bodies with nested attributes
    - Document relationship inclusion in responses
    - _Requirements: 8.1, 8.2, 8.3_
  
  - [x] 7.4 Document external API integration endpoint


    - Add rswag annotations to EnderecosController specs
    - Document GET /api/v1/enderecos/:cep endpoint
    - Include parameter descriptions and validation rules
    - Document both success and fallback response schemas
    - Add examples showing normal and fallback responses
    - Generate swagger.yaml with rake rswag:specs:swaggerize
    - _Requirements: 8.1, 8.2, 8.3, 8.4_

- [x] 8. Create comprehensive README documentation





  - Write README.md in repository root
  - Add project overview and technology stack section
  - Document all available endpoints with HTTP methods, paths, and descriptions
  - Add "Quick Start with Docker" section with docker-compose commands
  - Document Docker setup: docker-compose up --build, viewing logs, stopping containers
  - Add "Local Development without Docker" section with traditional setup steps
  - Document required Ruby and Rails versions
  - Include database migration commands for both Docker and non-Docker environments
  - Add example API requests using curl or HTTPie
  - Include example JSON responses for each endpoint
  - Document how to access Swagger documentation at /api-docs
  - Add section on running tests with rspec (both in Docker and locally)
  - Document environment variables and configuration
  - Add Docker-specific troubleshooting section (port conflicts, volume issues, etc.)
  - Document useful Docker commands (exec, logs, down -v, etc.)
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8, 11.9_

- [x] 9. Final integration and validation






  - Verify all endpoints are accessible under /api/v1 namespace
  - Test complete flow: create produto, create pedido with items, fetch CEP
  - Verify JSON:API format compliance in all responses
  - Test error scenarios: invalid data, missing resources, external API failures
  - Verify fallback responses work when external API is unavailable
  - Confirm Swagger documentation is accessible and accurate
  - Run full test suite and ensure all tests pass
  - Check code for any hardcoded values that should be environment variables
  - _Requirements: All requirements validation_

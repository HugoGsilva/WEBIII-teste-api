# Minha Loja API

A RESTful API microservice built with Ruby on Rails (API-only mode) for managing products and orders in an e-commerce platform. The system implements modern API design patterns including versioning, JSON:API serialization, and resilient external service integration.

## 📋 Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [API Endpoints](#api-endpoints)
- [Quick Start with Docker](#quick-start-with-docker)
- [Local Development without Docker](#local-development-without-docker)
- [API Documentation](#api-documentation)
- [Running Tests](#running-tests)
- [Environment Variables](#environment-variables)
- [Docker Commands Reference](#docker-commands-reference)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

**minha_loja_api** is a production-ready Rails API that provides:

- **Product Management**: Full CRUD operations for products with inventory tracking
- **Order Management**: Create and manage orders with line items and customer information
- **External API Integration**: Resilient integration with external services (CEP address lookup)
- **JSON:API Compliance**: Standardized response format following JSON:API specification
- **OpenAPI Documentation**: Interactive API documentation via Swagger UI
- **Docker Support**: Fully containerized for consistent development and deployment

### Key Features

- API versioning under `/api/v1` namespace
- Automatic retry logic with exponential backoff for external APIs
- Graceful fallback responses when external services are unavailable
- Comprehensive error handling and validation
- PostgreSQL database with proper indexing and relationships

## 🛠 Technology Stack

- **Ruby**: 3.2.x
- **Rails**: 7.x (API mode)
- **Database**: PostgreSQL 15
- **HTTP Client**: Faraday (for external API integration)
- **Serialization**: jsonapi-serializer
- **Documentation**: rswag (OpenAPI/Swagger)
- **Testing**: RSpec, FactoryBot, WebMock, Shoulda Matchers
- **Containerization**: Docker & Docker Compose

## 🚀 API Endpoints

### Products (Produtos)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/produtos` | List all products |
| GET | `/api/v1/produtos/:id` | Get a specific product |
| POST | `/api/v1/produtos` | Create a new product |
| PATCH | `/api/v1/produtos/:id` | Update a product |
| DELETE | `/api/v1/produtos/:id` | Delete a product |

### Orders (Pedidos)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/pedidos` | List all orders |
| GET | `/api/v1/pedidos/:id` | Get a specific order with items |
| POST | `/api/v1/pedidos` | Create a new order with items |
| PATCH | `/api/v1/pedidos/:id` | Update an order |
| DELETE | `/api/v1/pedidos/:id` | Delete an order |

### External Integration (Endereços)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/enderecos/:cep` | Fetch address information by CEP |

### Health Check

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/up` | Health check endpoint |

## 🐳 Quick Start with Docker

### Prerequisites

- Docker Desktop installed ([Download here](https://www.docker.com/products/docker-desktop))
- Docker Compose (included with Docker Desktop)

### Step 1: Build and Start Containers

```bash
# Build images and start all services
docker-compose up --build
```

This command will:
- Build the Rails application image
- Start PostgreSQL database container
- Start Rails application container
- Run database migrations automatically
- Start the Rails server on port 3000

### Step 2: Verify Installation

Open your browser and navigate to:
- API Health Check: http://localhost:3000/up
- Swagger Documentation: http://localhost:3000/api-docs

### Step 3: View Logs

```bash
# View logs from all containers
docker-compose logs -f

# View logs from specific service
docker-compose logs -f web
docker-compose logs -f db
```

### Step 4: Stop Containers

```bash
# Stop containers (preserves data)
docker-compose down

# Stop containers and remove volumes (deletes database data)
docker-compose down -v
```

## 💻 Local Development without Docker

### Prerequisites

- Ruby 3.2.x installed
- PostgreSQL 15 installed and running
- Bundler gem installed (`gem install bundler`)

### Step 1: Install Dependencies

```bash
# Install Ruby gems
bundle install
```

### Step 2: Configure Database

Create a `.env` file in the project root:

```bash
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/minha_loja_api_development
RAILS_ENV=development
```

Or update `config/database.yml` with your PostgreSQL credentials.

### Step 3: Setup Database

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# (Optional) Seed database
rails db:seed
```

### Step 4: Start Server

```bash
# Start Rails server
rails server -b 0.0.0.0

# Or use the shorthand
rails s
```

The API will be available at http://localhost:3000

## 📚 API Documentation

### Accessing Swagger UI

Interactive API documentation is available at:

```
http://localhost:3000/api-docs
```

The Swagger UI provides:
- Complete endpoint documentation
- Request/response schemas
- Interactive "Try it out" functionality
- Example requests and responses

### Example API Requests

#### Create a Product

```bash
curl -X POST http://localhost:3000/api/v1/produtos \
  -H "Content-Type: application/json" \
  -d '{
    "produto": {
      "name": "Notebook Dell",
      "description": "High-performance laptop",
      "price": 2999.99,
      "stock_quantity": 15
    }
  }'
```

**Response (201 Created):**
```json
{
  "data": {
    "id": "1",
    "type": "produto",
    "attributes": {
      "name": "Notebook Dell",
      "description": "High-performance laptop",
      "price": "2999.99",
      "stock_quantity": 15
    }
  }
}
```

#### List All Products

```bash
curl http://localhost:3000/api/v1/produtos
```

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "1",
      "type": "produto",
      "attributes": {
        "name": "Notebook Dell",
        "description": "High-performance laptop",
        "price": "2999.99",
        "stock_quantity": 15
      }
    }
  ]
}
```

#### Get a Specific Product

```bash
curl http://localhost:3000/api/v1/produtos/1
```

**Response (200 OK):**
```json
{
  "data": {
    "id": "1",
    "type": "produto",
    "attributes": {
      "name": "Notebook Dell",
      "description": "High-performance laptop",
      "price": "2999.99",
      "stock_quantity": 15
    }
  }
}
```

#### Create an Order with Items

```bash
curl -X POST http://localhost:3000/api/v1/pedidos \
  -H "Content-Type: application/json" \
  -d '{
    "pedido": {
      "customer_name": "João Silva",
      "status": "pending",
      "itens_attributes": [
        {
          "produto_id": 1,
          "quantity": 2,
          "unit_price": 2999.99
        }
      ]
    }
  }'
```

**Response (201 Created):**
```json
{
  "data": {
    "id": "1",
    "type": "pedido",
    "attributes": {
      "customer_name": "João Silva",
      "total_amount": "5999.98",
      "status": "pending"
    },
    "relationships": {
      "itens": {
        "data": [
          { "id": "1", "type": "item" }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "item",
      "attributes": {
        "quantity": 2,
        "unit_price": "2999.99"
      }
    }
  ]
}
```

#### Fetch Address by CEP

```bash
curl http://localhost:3000/api/v1/enderecos/01310100
```

**Response (200 OK - Success):**
```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "complemento": "",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP",
  "ibge": "3550308",
  "gia": "1004",
  "ddd": "11",
  "siafi": "7107"
}
```

**Response (200 OK - Fallback when external API is unavailable):**
```json
{
  "cep": "01310100",
  "logradouro": "Serviço temporariamente indisponível",
  "fallback": true
}
```

#### Update a Product

```bash
curl -X PATCH http://localhost:3000/api/v1/produtos/1 \
  -H "Content-Type: application/json" \
  -d '{
    "produto": {
      "price": 2799.99,
      "stock_quantity": 20
    }
  }'
```

#### Delete a Product

```bash
curl -X DELETE http://localhost:3000/api/v1/produtos/1
```

**Response (204 No Content)**

## 🧪 Running Tests

### With Docker

```bash
# Run all tests
docker-compose exec web rspec

# Run specific test file
docker-compose exec web rspec spec/models/produto_spec.rb

# Run tests with documentation format
docker-compose exec web rspec --format documentation

# Run tests and generate coverage report
docker-compose exec web rspec --format progress
```

### Without Docker (Local)

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/produto_spec.rb

# Run tests with documentation format
bundle exec rspec --format documentation

# Run tests matching a pattern
bundle exec rspec --tag focus
```

### Generate Swagger Documentation

```bash
# With Docker
docker-compose exec web rake rswag:specs:swaggerize

# Without Docker
bundle exec rake rswag:specs:swaggerize
```

## ⚙️ Environment Variables

### Development Environment

Create a `.env` file in the project root:

```bash
# Database Configuration
DATABASE_URL=postgresql://postgres:postgres@db:5432/minha_loja_api_development

# Rails Environment
RAILS_ENV=development
RAILS_LOG_TO_STDOUT=true

# External API Configuration (optional)
# CEP_API_TIMEOUT=10
# CEP_API_MAX_RETRIES=3
```

### Production Environment

```bash
# Database Configuration
DATABASE_URL=postgresql://user:password@host:5432/minha_loja_api_production

# Rails Environment
RAILS_ENV=production
SECRET_KEY_BASE=<your_secret_key_base>
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# External API Configuration
CEP_API_TIMEOUT=10
CEP_API_MAX_RETRIES=3
```

### Generating SECRET_KEY_BASE

```bash
# With Docker
docker-compose exec web rails secret

# Without Docker
rails secret
```

## 🐋 Docker Commands Reference

### Container Management

```bash
# Start containers in detached mode
docker-compose up -d

# Rebuild containers
docker-compose up --build

# Stop containers
docker-compose down

# Stop and remove volumes (deletes database data)
docker-compose down -v

# Restart a specific service
docker-compose restart web
```

### Viewing Logs

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs -f web

# View last 100 lines
docker-compose logs --tail=100 web
```

### Executing Commands

```bash
# Open Rails console
docker-compose exec web rails console

# Run database migrations
docker-compose exec web rails db:migrate

# Rollback last migration
docker-compose exec web rails db:rollback

# Reset database (drop, create, migrate)
docker-compose exec web rails db:reset

# Open bash shell in container
docker-compose exec web bash

# Run a one-off command
docker-compose run web rails db:seed
```

### Database Management

```bash
# Create database
docker-compose exec web rails db:create

# Run migrations
docker-compose exec web rails db:migrate

# Seed database
docker-compose exec web rails db:seed

# Reset database
docker-compose exec web rails db:reset

# Check migration status
docker-compose exec web rails db:migrate:status
```

### Cleaning Up

```bash
# Remove stopped containers
docker-compose rm

# Remove all unused containers, networks, images
docker system prune

# Remove all unused volumes
docker volume prune

# View disk usage
docker system df
```

## 🔧 Troubleshooting

### Docker-Specific Issues

#### Port 3000 Already in Use

**Problem**: Error message "port is already allocated"

**Solution**:
```bash
# Find process using port 3000
lsof -i :3000  # macOS/Linux
netstat -ano | findstr :3000  # Windows

# Kill the process or change port in docker-compose.yml
ports:
  - "3001:3000"  # Map to different host port
```

#### Database Connection Refused

**Problem**: Rails can't connect to PostgreSQL

**Solution**:
```bash
# Check if database container is running
docker-compose ps

# Check database logs
docker-compose logs db

# Restart database container
docker-compose restart db

# Ensure DATABASE_URL uses 'db' as host (not 'localhost')
DATABASE_URL=postgresql://postgres:postgres@db:5432/minha_loja_api_development
```

#### Volume Permission Issues

**Problem**: Permission denied errors when accessing files

**Solution**:
```bash
# On Linux, fix ownership
sudo chown -R $USER:$USER .

# Or run container as current user (add to docker-compose.yml)
user: "${UID}:${GID}"
```

#### Container Won't Start

**Problem**: Container exits immediately

**Solution**:
```bash
# View container logs
docker-compose logs web

# Check for syntax errors in code
docker-compose run web bundle exec ruby -c app/controllers/application_controller.rb

# Rebuild without cache
docker-compose build --no-cache
docker-compose up
```

#### Stale PID File

**Problem**: "A server is already running" error

**Solution**:
```bash
# Remove PID file
docker-compose exec web rm -f tmp/pids/server.pid

# Or restart container
docker-compose restart web
```

#### Bundle Install Issues

**Problem**: Gems not installing or version conflicts

**Solution**:
```bash
# Clear bundle cache and reinstall
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### General Issues

#### Migration Errors

**Problem**: Database schema out of sync

**Solution**:
```bash
# With Docker
docker-compose exec web rails db:migrate:status
docker-compose exec web rails db:migrate

# Reset database if needed
docker-compose exec web rails db:reset
```

#### External API Timeouts

**Problem**: CEP endpoint returns fallback responses

**Solution**:
- Check internet connectivity
- Verify external API is accessible: `curl https://viacep.com.br/ws/01310100/json/`
- Check timeout configuration in `app/services/external_api_service.rb`
- Review logs for retry attempts

#### Test Failures

**Problem**: Tests failing unexpectedly

**Solution**:
```bash
# Ensure test database is set up
docker-compose exec web rails db:test:prepare

# Run tests with verbose output
docker-compose exec web rspec --format documentation

# Run specific failing test
docker-compose exec web rspec spec/path/to/failing_spec.rb:line_number
```

## 📝 Additional Resources

- [Rails API Documentation](https://guides.rubyonrails.org/api_app.html)
- [JSON:API Specification](https://jsonapi.org/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [RSpec Documentation](https://rspec.info/)

## 📄 License

This project is available for use under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Built with ❤️ using Ruby on Rails**

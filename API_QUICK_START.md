# Minha Loja API - Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- Docker Desktop installed and running
- Git (for cloning the repository)

### Starting the Application

```bash
# Start the containers
docker-compose up

# In another terminal, setup the database (first time only)
docker-compose exec web bundle exec rails db:create db:migrate db:seed

# Generate Swagger documentation (optional)
docker-compose exec web bundle exec rake rswag:specs:swaggerize
```

### Stopping the Application

```bash
# Stop containers
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

### Rebuilding (if you encounter issues)

```bash
# Complete rebuild
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

---

## 📚 API Endpoints

### Base URL
```
http://localhost:3000/api/v1
```

### Swagger Documentation
```
http://localhost:3000/api-docs
```

---

## 🛍️ Produtos (Products)

### List all products
```bash
GET /api/v1/produtos
```

**Response:**
```json
{
  "data": [
    {
      "id": "1",
      "type": "produto",
      "attributes": {
        "name": "Notebook",
        "description": "High-performance laptop",
        "price": "2999.99",
        "stock_quantity": 10
      }
    }
  ]
}
```

### Get a specific product
```bash
GET /api/v1/produtos/:id
```

### Create a product
```bash
POST /api/v1/produtos
Content-Type: application/json

{
  "produto": {
    "name": "Gaming Mouse",
    "description": "High precision mouse",
    "price": 150.00,
    "stock_quantity": 25
  }
}
```

### Update a product
```bash
PATCH /api/v1/produtos/:id
Content-Type: application/json

{
  "produto": {
    "name": "Updated Name",
    "price": 199.99
  }
}
```

### Delete a product
```bash
DELETE /api/v1/produtos/:id
```

---

## 📦 Pedidos (Orders)

### List all orders
```bash
GET /api/v1/pedidos
```

**Response:**
```json
{
  "data": [
    {
      "id": "1",
      "type": "pedido",
      "attributes": {
        "customer_name": "John Doe",
        "total_amount": "5999.98",
        "status": "pending"
      },
      "relationships": {
        "itens": {
          "data": [
            {"id": "1", "type": "item"}
          ]
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "item",
      "attributes": {
        "quantity": 2,
        "unit_price": "2999.99"
      },
      "relationships": {
        "produto": {
          "data": {"id": "1", "type": "produto"}
        }
      }
    }
  ]
}
```

### Get a specific order
```bash
GET /api/v1/pedidos/:id
```

### Create an order with items
```bash
POST /api/v1/pedidos
Content-Type: application/json

{
  "pedido": {
    "customer_name": "John Doe",
    "status": "pending",
    "itens_attributes": [
      {
        "produto_id": 1,
        "quantity": 2,
        "unit_price": 2999.99
      },
      {
        "produto_id": 2,
        "quantity": 1,
        "unit_price": 150.00
      }
    ]
  }
}
```

**Note:** The `total_amount` is calculated automatically based on items.

### Update an order
```bash
PATCH /api/v1/pedidos/:id
Content-Type: application/json

{
  "pedido": {
    "status": "confirmed"
  }
}
```

**Valid status values:** `pending`, `confirmed`, `shipped`, `delivered`, `cancelled`

### Delete an order
```bash
DELETE /api/v1/pedidos/:id
```

---

## 📍 Endereços (CEP Lookup)

### Lookup address by CEP
```bash
GET /api/v1/enderecos/:cep
```

**Example:**
```bash
GET /api/v1/enderecos/01310100
```

**Response (Success):**
```json
{
  "cep": "01310-100",
  "logradouro": "Avenida Paulista",
  "complemento": "de 612 a 1510 - lado par",
  "bairro": "Bela Vista",
  "localidade": "São Paulo",
  "uf": "SP",
  "estado": "São Paulo",
  "regiao": "Sudeste",
  "ibge": "3550308",
  "gia": "1004",
  "ddd": "11",
  "siafi": "7107"
}
```

**Response (Fallback - when CEP not found or API unavailable):**
```json
{
  "cep": null,
  "logradouro": "Serviço temporariamente indisponível",
  "complemento": "",
  "bairro": "",
  "localidade": "",
  "uf": "",
  "fallback": true
}
```

**CEP Format:** 8 digits with or without hyphen (e.g., `01310100` or `01310-100`)

---

## ⚠️ Error Responses

### 404 Not Found
```json
{
  "error": "Couldn't find Produto with 'id'=\"99999\""
}
```

### 422 Unprocessable Entity (Validation Errors)
```json
{
  "errors": {
    "name": ["can't be blank"],
    "price": ["must be greater than 0"],
    "stock_quantity": ["must be greater than or equal to 0"]
  }
}
```

### 400 Bad Request (Invalid CEP)
```json
{
  "error": "CEP inválido. Formato esperado: 12345678 ou 12345-678"
}
```

---

## 🔧 Environment Variables

You can customize the API behavior using environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `CEP_API_URL` | `https://viacep.com.br/ws` | External CEP API base URL |
| `EXTERNAL_API_OPEN_TIMEOUT` | `5` | Connection timeout (seconds) |
| `EXTERNAL_API_READ_TIMEOUT` | `10` | Read timeout (seconds) |
| `EXTERNAL_API_MAX_RETRIES` | `3` | Maximum retry attempts |
| `DATABASE_URL` | - | PostgreSQL connection string |
| `DB_HOST` | `db` | Database host |
| `DB_USERNAME` | `postgres` | Database username |
| `DB_PASSWORD` | `postgres` | Database password |

**Example:**
```yaml
# docker-compose.yml
services:
  web:
    environment:
      - CEP_API_URL=https://viacep.com.br/ws
      - EXTERNAL_API_OPEN_TIMEOUT=10
      - EXTERNAL_API_MAX_RETRIES=5
```

---

## 🧪 Testing with cURL

### Create a product
```bash
curl -X POST http://localhost:3000/api/v1/produtos \
  -H "Content-Type: application/json" \
  -d '{"produto":{"name":"Test Product","price":99.99,"stock_quantity":5}}'
```

### Create an order
```bash
curl -X POST http://localhost:3000/api/v1/pedidos \
  -H "Content-Type: application/json" \
  -d '{"pedido":{"customer_name":"Jane Doe","status":"pending","itens_attributes":[{"produto_id":1,"quantity":1,"unit_price":99.99}]}}'
```

### Lookup CEP
```bash
curl http://localhost:3000/api/v1/enderecos/01310100
```

---

## 🐛 Troubleshooting

### Containers won't start
```bash
# Check if ports are in use
docker ps

# Stop all containers
docker-compose down

# Restart Docker Desktop
```

### Database connection errors
```bash
# Recreate database
docker-compose exec web bundle exec rails db:drop db:create db:migrate
```

### Controller not found errors
```bash
# Rebuild containers
docker-compose down -v
docker-compose build --no-cache
docker-compose up
```

### Swagger docs not showing
```bash
# Regenerate Swagger documentation
docker-compose exec web bundle exec rake rswag:specs:swaggerize
```

---

## 📖 Additional Resources

- **Swagger UI:** http://localhost:3000/api-docs
- **JSON:API Specification:** https://jsonapi.org/
- **ViaCEP API:** https://viacep.com.br/

---

## 🎯 Quick Test Workflow

```bash
# 1. Start the application
docker-compose up -d

# 2. Create a product
curl -X POST http://localhost:3000/api/v1/produtos \
  -H "Content-Type: application/json" \
  -d '{"produto":{"name":"Notebook","price":2999.99,"stock_quantity":10}}'

# 3. Create an order
curl -X POST http://localhost:3000/api/v1/pedidos \
  -H "Content-Type: application/json" \
  -d '{"pedido":{"customer_name":"John Doe","status":"pending","itens_attributes":[{"produto_id":1,"quantity":2,"unit_price":2999.99}]}}'

# 4. Lookup a CEP
curl http://localhost:3000/api/v1/enderecos/01310100

# 5. View all orders
curl http://localhost:3000/api/v1/pedidos

# 6. Open Swagger UI
# Visit: http://localhost:3000/api-docs
```

---

**Happy coding! 🚀**

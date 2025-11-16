# Minha Loja API

API RESTful desenvolvida com Ruby on Rails para gerenciamento de produtos e pedidos de uma loja virtual. Inclui integração com API externa de consulta de CEP (ViaCEP).

## 🛠 Tecnologias

- Ruby 3.2.x
- Rails 7.x (modo API)
- PostgreSQL 15
- Docker & Docker Compose
- RSpec (testes)
- Swagger/OpenAPI (documentação)

## 🚀 Iniciar o Projeto

### Pré-requisitos
- Docker Desktop instalado

### Comandos Básicos

```bash
# Iniciar aplicação
docker-compose up

# Iniciar em background
docker-compose up -d

# Parar aplicação
docker-compose down

# Parar e limpar dados
docker-compose down -v

# Reconstruir containers
docker-compose up --build
```

### Acessar a Aplicação

- **API**: http://localhost:3000
- **Swagger UI**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/up

## 📚 Endpoints da API

### Produtos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/produtos` | Listar todos |
| GET | `/api/v1/produtos/:id` | Buscar por ID |
| POST | `/api/v1/produtos` | Criar produto |
| PATCH | `/api/v1/produtos/:id` | Atualizar |
| DELETE | `/api/v1/produtos/:id` | Deletar |

### Pedidos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/pedidos` | Listar todos |
| GET | `/api/v1/pedidos/:id` | Buscar por ID |
| POST | `/api/v1/pedidos` | Criar pedido |
| PATCH | `/api/v1/pedidos/:id` | Atualizar |
| DELETE | `/api/v1/pedidos/:id` | Deletar |

### Endereços (CEP)

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/enderecos/:cep` | Consultar CEP |

## 🧪 Comandos para Testes

### Executar Testes

```bash
# Rodar todos os testes
docker-compose exec web bundle exec rspec

# Rodar testes com detalhes
docker-compose exec web bundle exec rspec --format documentation

# Rodar teste específico
docker-compose exec web bundle exec rspec spec/requests/api/v1/produtos_spec.rb
```

### Gerar Documentação Swagger

```bash
docker-compose exec web bundle exec rake rswag:specs:swaggerize
```

## 🗄️ Comandos de Banco de Dados

```bash
# Criar banco de dados
docker-compose exec web bundle exec rails db:create

# Rodar migrations
docker-compose exec web bundle exec rails db:migrate

# Popular banco (seed)
docker-compose exec web bundle exec rails db:seed

# Resetar banco (apaga tudo e recria)
docker-compose exec web bundle exec rails db:reset

# Limpar apenas dados (mantém estrutura)
docker-compose exec web bundle exec rails db:seed:replant

# Abrir console Rails
docker-compose exec web bundle exec rails console
```

### Limpar Dados Manualmente (via Console)

```bash
# Abrir console
docker-compose exec web bundle exec rails console

# Dentro do console, executar:
Pedido.destroy_all
Produto.destroy_all
```

## 📋 Exemplos de Requisições

### Criar Produto

```bash
curl -X POST http://localhost:3000/api/v1/produtos \
  -H "Content-Type: application/json" \
  -d '{
    "produto": {
      "name": "Notebook",
      "description": "Notebook Dell",
      "price": 2999.99,
      "stock_quantity": 10
    }
  }'
```

### Listar Produtos

```bash
curl http://localhost:3000/api/v1/produtos
```

### Criar Pedido

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

### Consultar CEP

```bash
curl http://localhost:3000/api/v1/enderecos/01310100
```

## 🔍 Comandos de Debug

```bash
# Ver logs em tempo real
docker-compose logs -f web

# Ver últimas 100 linhas de log
docker-compose logs --tail=100 web

# Verificar status dos containers
docker-compose ps

# Acessar bash do container
docker-compose exec web bash

# Verificar status das migrations
docker-compose exec web bundle exec rails db:migrate:status
```

## ⚠️ Solução de Problemas

### Porta 3000 em uso

```bash
# Windows
netstat -ano | findstr :3000

# Ou alterar porta no docker-compose.yml
ports:
  - "3001:3000"
```

### Erro "database is being accessed"

```bash
# Parar containers e reiniciar
docker-compose down
docker-compose up
```

### Limpar tudo e recomeçar

```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up
docker-compose exec web bundle exec rails db:create db:migrate
```

## 📖 Testando via Swagger UI

1. Acesse: http://localhost:3000/api-docs
2. Clique em qualquer endpoint
3. Clique em "Try it out"
4. Preencha os dados
5. Clique em "Execute"

### Fluxo de Teste Recomendado

1. **Criar produtos** (POST /produtos)
2. **Listar produtos** (GET /produtos)
3. **Criar pedido** com os produtos criados (POST /pedidos)
4. **Listar pedidos** (GET /pedidos)
5. **Consultar CEP** (GET /enderecos/01310100)
6. **Atualizar status** do pedido (PATCH /pedidos/:id)

## 📝 Validações Importantes

### Produto
- `name`: obrigatório
- `price`: obrigatório, maior que 0
- `stock_quantity`: obrigatório, maior ou igual a 0

### Pedido
- `customer_name`: obrigatório
- `status`: valores válidos: `pending`, `confirmed`, `shipped`, `delivered`, `cancelled`
- `itens_attributes`: obrigatório (pelo menos 1 item)

### CEP
- Formato: 8 dígitos (com ou sem hífen)
- Exemplo válido: `01310100` ou `01310-100`

## 🎯 Comandos Rápidos para Apresentação

```bash
# 1. Iniciar projeto
docker-compose up -d

# 2. Verificar se está rodando
curl http://localhost:3000/up

# 3. Abrir Swagger no navegador
# http://localhost:3000/api-docs

# 4. Ver logs (se necessário)
docker-compose logs -f web

# 5. Limpar dados entre testes
docker-compose exec web bundle exec rails runner "Pedido.destroy_all; Produto.destroy_all"

# 6. Parar ao final
docker-compose down
```

---

**Desenvolvido com Ruby on Rails** 🚀

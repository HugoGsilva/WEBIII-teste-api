class ProdutoSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :stock_quantity
end

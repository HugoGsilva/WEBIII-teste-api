class PedidoSerializer
  include JSONAPI::Serializer

  attributes :customer_name, :total_amount, :status

  has_many :itens, serializer: ItemSerializer
end

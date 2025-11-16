class ItemSerializer
  include JSONAPI::Serializer

  attributes :quantity, :unit_price

  belongs_to :produto
end

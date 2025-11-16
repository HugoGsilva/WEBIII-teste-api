class Item < ApplicationRecord
  belongs_to :pedido
  belongs_to :produto

  validates :produto_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
end

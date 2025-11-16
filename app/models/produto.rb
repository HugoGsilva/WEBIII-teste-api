class Produto < ApplicationRecord
  has_many :itens

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { 
    only_integer: true, 
    greater_than_or_equal_to: 0 
  }
end

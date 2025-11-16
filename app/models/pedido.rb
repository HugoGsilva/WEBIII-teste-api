class Pedido < ApplicationRecord
  has_many :itens, class_name: 'Item', dependent: :destroy
  accepts_nested_attributes_for :itens

  validates :customer_name, presence: true
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { 
    in: %w[pending confirmed shipped delivered cancelled] 
  }

  before_validation :calculate_total_amount

  private

  def calculate_total_amount
    if itens.any?
      self.total_amount = itens.sum { |item| (item.quantity || 0) * (item.unit_price || 0) }
    end
  end
end

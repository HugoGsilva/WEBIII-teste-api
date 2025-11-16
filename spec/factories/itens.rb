# frozen_string_literal: true

FactoryBot.define do
  factory :item do
    association :pedido
    association :produto
    quantity { 1 }
    unit_price { 99.99 }
  end
end

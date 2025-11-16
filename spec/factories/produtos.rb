# frozen_string_literal: true

FactoryBot.define do
  factory :produto do
    sequence(:name) { |n| "Produto #{n}" }
    description { "Descrição do produto" }
    price { 99.99 }
    stock_quantity { 10 }
  end
end

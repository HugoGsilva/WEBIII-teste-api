# frozen_string_literal: true

FactoryBot.define do
  factory :pedido do
    sequence(:customer_name) { |n| "Cliente #{n}" }
    total_amount { 0.0 }
    status { "pending" }
  end
end

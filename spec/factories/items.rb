FactoryBot.define do
  factory :item do
    association :invoice
    description { "Product" }
    quantity { 1 }
    unit_price { 1000 }
  end
end
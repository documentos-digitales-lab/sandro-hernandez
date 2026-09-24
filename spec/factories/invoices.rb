FactoryBot.define do
  factory :invoice do
    association :customer
    uuid { SecureRandom.uuid }
    subtotal { 0 }
    tax { 0 }
    total { 0 }

    to_create { |invoice| invoice.save!(validate: false) }

    trait :with_item do
      after(:build) do |invoice|
        invoice.items.build(description: "Product", quantity: 1, unit_price: 1000)
      end
    end
  end
end
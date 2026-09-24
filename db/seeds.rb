# Demo data so the interview reviewer can log in and explore the flow.
# Idempotent: safe to run multiple times with `bin/rails db:seed`.

customer = Customer.find_or_create_by!(rfc: "SEED1234567890")

unless customer.invoices.exists?(uuid: "seed-invoice-001")
  customer.invoices.create!(uuid: "seed-invoice-001") do |invoice|
    invoice.items.new(description: "Laptop", quantity: 1, unit_price: 1500)
    invoice.items.new(description: "Monitor", quantity: 2, unit_price: 200)
  end
end

puts "Seeded customer RFC=SEED1234567890 (login) with one invoice."
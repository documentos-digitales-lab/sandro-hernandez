require "rails_helper"

RSpec.describe AdditionalTaxesChecker, type: :service do
  let(:invoice) { create(:invoice) }

  def add_item(description: "Product", quantity: 1, unit_price:)
    invoice.items.create!(description: description, quantity: quantity, unit_price: unit_price)
  end

  describe ".call" do
    context "when every product tax is at or below the threshold" do
      it "returns false", :aggregate_failures do
        add_item(quantity: 1, unit_price: 1000)    # tax 160
        add_item(quantity: 1, unit_price: 2500)    # tax 400

        expect(described_class.call(invoice)).to be false
      end

      it "returns false at exactly the threshold" do
        # 12500 * 0.16 = 2000 (not above the threshold)
        add_item(quantity: 1, unit_price: 12500)

        expect(described_class.call(invoice)).to be false
      end

      it "returns false when the tax rounds to exactly the threshold" do
        # 12500.01 * 0.16 = 2000.0016, tax rounds to 2000.00
        add_item(quantity: 1, unit_price: 12500.01)

        expect(described_class.call(invoice)).to be false
      end

      it "returns true as soon as the tax rounds above the threshold" do
        # 12500.04 * 0.16 = 2000.0064, tax rounds to 2000.01
        add_item(quantity: 1, unit_price: 12500.04)

        expect(described_class.call(invoice)).to be true
      end
    end

    context "when at least one product tax exceeds the threshold" do
      it "returns true", :aggregate_failures do
        add_item(quantity: 1, unit_price: 15000)   # tax 2400
        add_item(quantity: 1, unit_price: 1000)    # tax 160

        expect(described_class.call(invoice)).to be true
      end
    end

    context "with multiple products whose combined tax exceeds the threshold" do
      it "returns false because the rule applies per product" do
        add_item(quantity: 1, unit_price: 7000)   # tax 1120
        add_item(quantity: 1, unit_price: 7000)   # tax 1120 (combined 2240 but each ≤ 2000)

        expect(described_class.call(invoice)).to be false
      end
    end

    context "with no items" do
      it "returns false" do
        expect(described_class.call(invoice)).to be false
      end
    end
  end
end
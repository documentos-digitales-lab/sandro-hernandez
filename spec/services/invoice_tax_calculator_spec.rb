require "rails_helper"

RSpec.describe InvoiceTaxCalculator, type: :service do
  let(:invoice) { create(:invoice) }

  def add_item(description: "Product", quantity:, unit_price:)
    invoice.items.create!(description: description, quantity: quantity, unit_price: unit_price)
  end

  describe ".call" do
    subject(:result) { described_class.call(invoice) }

    context "with no items" do
      it "returns a zeroed result" do
        expect(result.subtotal).to eq(BigDecimal("0"))
        expect(result.tax).to eq(BigDecimal("0"))
        expect(result.total).to eq(BigDecimal("0"))
        expect(result.tax_per_product).to eq([])
      end
    end

    context "with one item" do
      before { add_item(quantity: 1, unit_price: 1000) }

      it "computes subtotal, 16% tax and total" do
        expect(result.subtotal).to eq(BigDecimal("1000"))
        expect(result.tax).to eq(BigDecimal("160"))
        expect(result.total).to eq(BigDecimal("1160"))
        expect(result.tax_per_product).to eq([BigDecimal("160")])
      end
    end

    context "with several items" do
      before do
        add_item(description: "Laptop", quantity: 1, unit_price: 1000)
        add_item(description: "Mouse", quantity: 2, unit_price: 500.50)
      end

      it "sums the amounts and taxes each product separately" do
        expect(result.subtotal).to eq(BigDecimal("2001"))
        expect(result.tax).to eq(BigDecimal("320.16"))
        expect(result.total).to eq(BigDecimal("2321.16"))
        expect(result.tax_per_product).to eq([BigDecimal("160"), BigDecimal("160.16")])
      end
    end

    context "with large values" do
      before { add_item(quantity: 1, unit_price: 200000) }

      it "computes the tax accurately with decimals" do
        expect(result.tax).to eq(BigDecimal("32000"))
        expect(result.tax_per_product).to eq([BigDecimal("32000")])
      end
    end

    context "with an item that is missing its unit price" do
      it "is rejected by item validations so it never reaches the calculator" do
        invoice.items.build(description: "Incomplete", quantity: 1, unit_price: nil)

        expect(invoice).to be_invalid
      end
    end

    context "with an in-memory item of quantity zero" do
      it "treats the row as zero" do
        invoice.items.build(description: "Unused", quantity: 0, unit_price: 500)

        expect(result.subtotal).to eq(BigDecimal("0"))
        expect(result.tax).to eq(BigDecimal("0"))
        expect(result.total).to eq(BigDecimal("0"))
      end
    end

    context "with sub-cent amounts that survive on unsaved items" do
      it "rounds each amount and each per-product tax half-up to two decimals" do
        invoice.items.build(description: "A", quantity: 1, unit_price: BigDecimal("0.005"))
        invoice.items.build(description: "B", quantity: 1, unit_price: BigDecimal("0.31"))

        expect(result.subtotal).to eq(BigDecimal("0.32"))
        expect(result.tax).to eq(BigDecimal("0.05"))
        expect(result.total).to eq(BigDecimal("0.37"))
        expect(result.tax_per_product).to eq([BigDecimal("0.00"), BigDecimal("0.05")])
      end
    end

    context "with a floating-point-looking unit price" do
      it "does not accumulate float artifacts" do
        add_item(quantity: 3, unit_price: 0.1)

        expect(result.subtotal).to eq(BigDecimal("0.30"))
        expect(result.total).to eq(BigDecimal("0.35"))
      end
    end

    it "rounds each per-product amount to two decimals" do
      add_item(quantity: 1, unit_price: 6103.125)

      expect(result.subtotal).to eq(BigDecimal("6103.13"))
    end
  end
end
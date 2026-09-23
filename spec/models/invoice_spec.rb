require "rails_helper"

RSpec.describe Invoice, type: :model do
  let(:customer) { create(:customer) }

  describe "associations" do
    it { is_expected.to have_many(:items).dependent(:destroy) }
  end

  describe "nested attributes" do
    it "accepts nested attributes for items" do
      expect(described_class.new).to accept_nested_attributes_for(:items)
    end
  end

  describe "uuid" do
    it "generates a uuid when none is provided" do
      invoice = build(:invoice, uuid: nil)

      invoice.valid?

      expect(invoice.uuid).to be_present
    end

    it "keeps an existing uuid" do
      invoice = build(:invoice, uuid: "my-custom-key")

      invoice.valid?

      expect(invoice.uuid).to eq("my-custom-key")
    end
  end

  describe "to_param" do
    it "returns the uuid" do
      invoice = build(:invoice, uuid: "abc-123")

      expect(invoice.to_param).to eq("abc-123")
    end
  end

  describe "validation of at least one product" do
    it "is invalid without any active item" do
      invoice = build(:invoice)

      expect(invoice).not_to be_valid
      expect(invoice.errors[:base]).to include("At least one product is required.")
    end

    it "is valid with an active item" do
      invoice = build(:invoice)
      invoice.items.build(description: "Laptop", quantity: 1, unit_price: 1000)

      expect(invoice).to be_valid
    end

    it "is invalid when every item has a non-positive quantity" do
      invoice = Invoice.new(customer: customer, items_attributes: {
        "0" => { description: "A", quantity: "0", unit_price: "10" },
        "1" => { description: "B", quantity: "-1", unit_price: "20" }
      })

      expect(invoice.items).to be_empty
      expect(invoice).not_to be_valid
      expect(invoice.errors[:base]).to include("At least one product is required.")
    end
  end

  describe "dependent destroy" do
    it "destroys its items when the invoice is destroyed" do
      invoice = create(:invoice, :with_item)

      expect { invoice.destroy }.to change(Item, :count).by(-1)
    end
  end

  describe "rejecting inactive items" do
    it "drops items whose quantity is zero" do
      invoice = Invoice.new(customer: customer, items_attributes: {
        "0" => { description: "Laptop", quantity: "1", unit_price: "1000" },
        "1" => { description: "Warranty", quantity: "0", unit_price: "50" }
      })

      expect(invoice.items.map(&:description)).to eq(["Laptop"])
    end

    it "drops items whose quantity is negative" do
      invoice = Invoice.new(customer: customer, items_attributes: {
        "0" => { description: "Laptop", quantity: "-1", unit_price: "1000" }
      })

      expect(invoice.items).to be_empty
    end

    it "keeps an item with a blank quantity so the error surfaces" do
      invoice = Invoice.new(customer: customer, items_attributes: {
        "0" => { description: "Laptop", quantity: "", unit_price: "1000" }
      })

      expect(invoice.items.size).to eq(1)
      expect(invoice).not_to be_valid
      expect(invoice.items.first.errors[:quantity]).to include("can't be blank")
    end
  end
end
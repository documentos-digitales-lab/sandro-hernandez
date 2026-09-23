require "rails_helper"

RSpec.describe Item, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:invoice) }
  end

  describe "validations" do
    subject { build(:item) }

    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
  end

  describe "edge cases" do
    it "rejects a non-integer quantity" do
      expect(build(:item, quantity: 1.5)).to be_invalid
    end

    it "rejects a zero quantity" do
      expect(build(:item, quantity: 0)).to be_invalid
    end

    it "rejects a negative unit price" do
      expect(build(:item, unit_price: -1)).to be_invalid
    end

    it "accepts a zero unit price" do
      expect(build(:item, unit_price: 0)).to be_valid
    end
  end

  describe "#amount" do
    it "multiplies quantity by unit price" do
      item = build(:item, quantity: 3, unit_price: 150.50)

      expect(item.amount).to eq(451.50)
    end

    it "keeps decimal precision" do
      item = build(:item, quantity: 3, unit_price: 0.10)

      expect(item.amount).to eq(BigDecimal("0.30"))
    end

    it "returns zero for a zero quantity" do
      expect(build(:item, quantity: 0, unit_price: 10).amount).to eq(0)
    end

    it "returns zero when the unit price is missing" do
      expect(build(:item, unit_price: nil).amount).to eq(0)
    end
  end
end
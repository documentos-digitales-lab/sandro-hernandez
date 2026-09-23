require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:invoices).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:customer) }

    it { is_expected.to validate_presence_of(:rfc) }
    it { is_expected.to validate_uniqueness_of(:rfc).case_insensitive }
  end

  describe "RFC normalization" do
    it "strips surrounding whitespace and upcases the RFC" do
      customer = create(:customer, rfc: "  abc220101xyz  ")

      expect(customer.rfc).to eq("ABC220101XYZ")
    end

    it "rejects an RFC that is only whitespace" do
      expect(build(:customer, rfc: "   ")).to be_invalid
    end

    it "rejects a nil RFC" do
      expect(build(:customer, rfc: nil)).to be_invalid
    end
  end
end
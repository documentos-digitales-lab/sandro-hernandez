require "rails_helper"

RSpec.describe InvoiceHelper, type: :helper do
  describe "#additional_taxes_message" do
    it "returns the warning message when additional taxes are required" do
      expect(helper.additional_taxes_message(true))
        .to eq("Additional taxes are needed for this invoice.")
    end

    it "returns the confirmation message otherwise" do
      expect(helper.additional_taxes_message(false))
        .to eq("No additional taxes are needed.")
    end
  end

  describe "#bootstrap_field_class" do
    let(:object) { Item.new }

    it "adds the invalid class when the attribute has errors" do
      object.errors.add(:description, "can't be blank")

      expect(helper.bootstrap_field_class(object, :description)).to eq("form-control is-invalid")
    end

    it "returns the base form-control class when there are no errors" do
      expect(helper.bootstrap_field_class(object, :description)).to eq("form-control")
    end
  end
end
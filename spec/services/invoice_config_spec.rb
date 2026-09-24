require "rails_helper"

RSpec.describe InvoiceConfig do
  describe ".tax_rate" do
    it "uses 0.16 by default" do
      ENV.delete("INVOICE_TAX_RATE")

      expect(InvoiceConfig.tax_rate).to eq(BigDecimal("0.16"))
    end

    it "reads the value from the environment" do
      ENV["INVOICE_TAX_RATE"] = "0.20"

      expect(InvoiceConfig.tax_rate).to eq(BigDecimal("0.20"))
    ensure
      ENV.delete("INVOICE_TAX_RATE")
    end
  end

  describe ".high_tax_threshold" do
    it "uses 2000 by default" do
      ENV.delete("ADDITIONAL_TAXES_THRESHOLD")

      expect(InvoiceConfig.high_tax_threshold).to eq(BigDecimal("2000"))
    end

    it "reads the value from the environment" do
      ENV["ADDITIONAL_TAXES_THRESHOLD"] = "2500"

      expect(InvoiceConfig.high_tax_threshold).to eq(BigDecimal("2500"))
    ensure
      ENV.delete("ADDITIONAL_TAXES_THRESHOLD")
    end
  end
end
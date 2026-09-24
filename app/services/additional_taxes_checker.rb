class AdditionalTaxesChecker
  def self.call(invoice)
    new(invoice).call
  end

  def initialize(invoice)
    @invoice = invoice
  end

  def call
    InvoiceTaxCalculator.call(invoice).tax_per_product.any? { |tax| tax > InvoiceConfig.high_tax_threshold }
  end

  private

  attr_reader :invoice
end
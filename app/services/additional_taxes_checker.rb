class AdditionalTaxesChecker
  HIGH_TAX_THRESHOLD = BigDecimal("2000")

  def self.call(invoice)
    new(invoice).call
  end

  def initialize(invoice)
    @invoice = invoice
  end

  def call
    InvoiceTaxCalculator.call(invoice).tax_per_product.any? { |tax| tax > HIGH_TAX_THRESHOLD }
  end

  private

  attr_reader :invoice
end
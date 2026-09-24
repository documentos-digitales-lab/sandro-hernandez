class InvoiceTaxCalculator
  Result = Struct.new(:subtotal, :tax, :total, :tax_per_product, keyword_init: true)

  def self.call(invoice)
    new(invoice).call
  end

  def initialize(invoice)
    @invoice = invoice
  end

  def call
    amounts = items.map { |li| li.amount.round(2) }
    subtotal = amounts.sum.round(2)
    tax = (subtotal * InvoiceConfig.tax_rate).round(2)
    Result.new(
      subtotal: subtotal,
      tax: tax,
      total: (subtotal + tax).round(2),
      tax_per_product: amounts.map { |a| (a * InvoiceConfig.tax_rate).round(2) }
    )
  end

  private

  attr_reader :invoice

  def items
    invoice.items
  end
end
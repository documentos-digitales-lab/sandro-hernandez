# Environment-driven business rules so rates and thresholds can change in
# deployment without touching code. Fallback defaults apply when the
# variables are not set.
module InvoiceConfig
  module_function

  def tax_rate
    BigDecimal(ENV.fetch("INVOICE_TAX_RATE", "0.16"))
  end

  def high_tax_threshold
    BigDecimal(ENV.fetch("ADDITIONAL_TAXES_THRESHOLD", "2000"))
  end
end
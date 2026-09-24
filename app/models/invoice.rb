class Invoice < ApplicationRecord
  belongs_to :customer
  has_many :items, dependent: :destroy
  accepts_nested_attributes_for :items,
    reject_if: :unused_item?

  before_validation { self.uuid = SecureRandom.uuid if uuid.blank? }
  before_save :persist_totals
  validate :at_least_one_product

  def to_param
    uuid
  end

  private

  def at_least_one_product
    errors.add(:base, "At least one product is required.") if items.size < 1
  end

  def unused_item?(attrs)
    !attrs["quantity"].to_s.empty? && attrs["quantity"].to_i <= 0
  end

  def persist_totals
    result = InvoiceTaxCalculator.call(self)
    self.subtotal = result.subtotal
    self.tax = result.tax
    self.total = result.total
  end
end
class Invoice < ApplicationRecord
  has_many :items, dependent: :destroy
  accepts_nested_attributes_for :items,
    reject_if: ->(attrs) { !attrs["quantity"].to_s.empty? && attrs["quantity"].to_i <= 0 }
  validate :at_least_one_product

  before_validation { self.uuid = SecureRandom.uuid if uuid.blank? }

  def to_param
    uuid
  end

  private

  def at_least_one_product
    errors.add(:base, "At least one product is required.") if items.size < 1
  end
end
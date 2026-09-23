class Customer < ApplicationRecord
  has_many :invoices, dependent: :destroy

  before_validation { self.rfc = rfc.to_s.strip.upcase }

  validates :rfc, presence: true, uniqueness: true
end

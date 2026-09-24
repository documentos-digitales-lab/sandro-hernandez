class Item < ApplicationRecord
  belongs_to :invoice
  validates :description, :quantity, :unit_price, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  def amount
    quantity * unit_price
  end
end
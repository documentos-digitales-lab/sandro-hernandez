class Customer < ApplicationRecord
  validates :rfc, presence: true
end

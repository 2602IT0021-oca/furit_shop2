class Order < ApplicationRecord
  belongs_to :product
  belongs_to :user
  validates :count, numericality: { only_integer: true, greater_than: 0 }
  validates :address, presence: true
end

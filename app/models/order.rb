class Order < ApplicationRecord
  belongs_to :user

  has_many :order_details
  has_many :products, through: :order_details

  accepts_nested_attributes_for :order_details

  validates :address, presence: true
end
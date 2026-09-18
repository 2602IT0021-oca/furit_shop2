class Product < ApplicationRecord

  validates :name, presence: true, uniqueness: true  # 商品名は必須で一意
  validates :price, presence: true

  has_one_attached :photo

  has_many :cart_items
  has_many :order_details
  has_many :orders, through: :order_details

  def thumbnail
    photo.variant(resize_to_limit: [150, 150]).processed
  end

end

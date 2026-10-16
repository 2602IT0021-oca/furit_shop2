class Product < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    %w[name price]
  end
  def self.ransackable_associations(auth_object = nil)
  []
end
  enum :status, { on_sale: 0, sold_out: 1 }
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

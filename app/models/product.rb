class Product < ApplicationRecord
    validates :name, presence: true, uniqueness: true  # 商品名は必須で一意
    validates :price, presence: true    
end

class User < ApplicationRecord
 devise :database_authenticatable, :registerable,
        :trackable, :rememberable, :validatable
        has_many :orders
end
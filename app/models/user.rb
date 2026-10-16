class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :trackable, :rememberable, :validatable

  has_many :orders
  has_one :cart
  has_one_attached :photo

  belongs_to :employee, optional: true
  def self.ransackable_attributes(auth_object = nil)
  %w[id name email age employee_id]
end

def self.ransackable_associations(auth_object = nil)
  %w[employee]
end
end
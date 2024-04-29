class Order < ApplicationRecord
  belongs_to :user
  belongs_to :address
  has_many :order_items, dependent: :destroy
  has_many :product_items, through: :order_items
  validates :total_amount, :status, presence: true
end

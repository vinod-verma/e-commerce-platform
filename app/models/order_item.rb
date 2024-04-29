class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product_item
  validates :qty, :price, presence: true
end

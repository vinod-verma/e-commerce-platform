class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product_item
  validates :qty, presence: true
  validates :product_item_id, uniqueness: true
end

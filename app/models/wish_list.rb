class WishList < ApplicationRecord
  belongs_to :user
  has_many :wish_list_items, dependent: :destroy
end

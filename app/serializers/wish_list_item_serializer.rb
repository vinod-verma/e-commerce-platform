class WishListItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :product_item_id
end
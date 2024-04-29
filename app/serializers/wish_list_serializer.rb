class WishListSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id

  attribute :wish_list_items do |wish_list|
    wish_list.wish_list_items.each do |wish_list_item|
      # CartItemSerializer.new(cart_item).serializable_hash rescue ''
    end    
  end
end
class CartSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :user_id
  
  attribute :cart_items do |cart|
    cart.cart_items.each do |cart_item|
      CartItemSerializer.new(cart_item).serializable_hash rescue ''
    end    
  end
end
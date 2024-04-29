class CartItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :qty, :cart_id, :product_item_id

  attribute :product_item do |cart_item|
    product_item = ProductItem.find(cart_item.product_item_id)
    ProductItemSerializer.new(product_item).serializable_hash rescue ''
  end
end
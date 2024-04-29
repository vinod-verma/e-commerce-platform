class OrderItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :order_id, :product_item_id, :qty, :price, :created_at
end
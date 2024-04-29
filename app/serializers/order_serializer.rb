class OrderSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :total_amount, :status
  
  attribute :order_items do |order|
    OrderItemSerializer.new(order.order_items).serializable_hash
  end

  attribute :address do |order|
    AddressSerializer.new(order.address).serializable_hash
  end
end
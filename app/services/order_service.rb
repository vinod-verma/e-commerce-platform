class OrderService
  attr_reader :order, :errors

  def initialize(user, cart_items, address)
    @user = user
    @cart_items = cart_items
    @order = nil
    @errors = []
    @address = address
  end

  def create_order
    @order = @user.orders.build(total_amount: calculate_total_price, status: :pending, address: @address)
    return false unless @order.save

    @cart_items.each do |cart_item|
      product_item = cart_item.product_item
      qty = cart_item.qty
      price = product_item.price.to_f * qty
      order_item = @order.order_items.build(product_item_id: product_item.id, qty: qty, price: price)
      @errors.concat(order_item.errors.full_messages) unless order_item.save
    end

    @errors.empty?
  end

  private

  def calculate_total_price
    @cart_items.sum { |cart_item| cart_item.product_item.price.to_f * cart_item.qty }
  end
end

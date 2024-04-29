class OrdersController < ApplicationController
  before_action :authorize_request

  def index
    orders = @current_user.orders.includes(:order_items)
    render json: OrderSerializer.new(orders).serializable_hash, status: :ok
  end

  def create
    cart_items = @current_user.cart.cart_items.includes(:product_item)
    if cart_items.empty?
      render json: { message: "Cart is empty." }, status: :unprocessable_entity
      return
    end
    address = @current_user.addresses.find(params[:address_id])
    unless address
      render json: { message: "Address not found." }, status: :unprocessable_entity
      return
    end
    order_service = OrderService.new(@current_user, cart_items, address)
    if order_service.create_order
      render json: OrderSerializer.new(order_service.order).serializable_hash, status: :created
    else
      render json: { errors: order_service.errors }, status: :unprocessable_entity
    end
  end

  def update
    order = @current_user.orders.find_by(id: params[:id])
    unless order
      render json: { message: "Order not found." }, status: :unprocessable_entity
      return
    end

    if order.update(status: 'cancle')
      render json: OrderSerializer.new(order).serializable_hash, status: :ok
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  end
end


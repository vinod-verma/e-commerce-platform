class CartsController < ApplicationController
  before_action :authorize_request
  before_action :set_cart

  def show
    render json: CartSerializer.new(@cart).serializable_hash, status: :ok
  end

  def add_item
    product_item = ProductItem.find(params[:product_item_id])
    quantity = params[:quantity].to_i

    cart_item = @cart.cart_items.new(product_item: product_item, qty: quantity)

    if cart_item.save
      render json: CartSerializer.new(@cart).serializable_hash, status: :ok
    else
      render json: { errors: cart_item.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def remove_item
    cart_item = @cart.cart_items.find(params[:cart_item_id])

    if cart_item.destroy
      render json: {message: "#{cart_item.product_item.product.name} removed from cart."}, status: :ok
    else
      render json: { errors: cart_item.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update_quantity
    cart_item = @cart.cart_items.find(params[:cart_item_id])
    quantity = params[:quantity].to_i

    if cart_item.update(qty: quantity)
      render json: CartSerializer.new(@cart).serializable_hash, status: :ok
    else
      render json: { errors: cart_item.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_cart
    @cart = @current_user.cart
    @cart = @current_user.create_cart unless @cart
  end
end

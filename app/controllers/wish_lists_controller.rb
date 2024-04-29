class WishListsController < ApplicationController
  before_action :authorize_request
  before_action :set_wish_list

  def show
    render json: WishListSerializer.new(@wish_list).serializable_hash, status: :ok
  end

  def add_item
    product_item = ProductItem.find(params[:product_item_id])

    wish_list_item = @wish_list.wish_list_items.new(product_item: product_item)

    if wish_list_item.save
      render json: WishListSerializer.new(@wish_list).serializable_hash, status: :ok
    else
      render json: { errors: wish_list_item.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def remove_item
    wish_list_item = @wish_list.wish_list_items.find(params[:wish_list_item_id])

    if wish_list_item.destroy
      render json: { message: "#{wish_list_item.product_item.product.name} removed from wishlist." }, status: :ok
    else
      render json: { errors: wish_list_item.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def set_wish_list
    @wish_list = @current_user.wish_list
    @wish_list = @current_user.create_wish_list unless @wish_list
  end
end

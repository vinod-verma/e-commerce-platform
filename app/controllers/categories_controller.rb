class CategoriesController < ApplicationController
  before_action :authorize_request

  def index
    @categories  = Category.where(parent_category_id: params[:parent_category_id])
    render json: CategorySerializer.new(@categories).serializable_hash, status: :ok
  end

  def get_product
    product_item = ProductItem.find(params[:id])
    if product_item
      render json: ProductItemSerializer.new(product_item).serializable_hash, status: :ok
    elsif
      render json: {message: "Product not found"}, status: :unprocessable_entity
    end
  end
end

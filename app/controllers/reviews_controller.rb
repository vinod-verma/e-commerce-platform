class ReviewsController < ApplicationController
  # include ActiveStorage::Blob::Analyzable
  before_action :authorize_request
  before_action :set_review, only: [:show, :update]

  def index
    product_reviews = Product.find(params[:product_id]).reviews
    render json: ReviewSerializer.new(product_reviews).serializable_hash, status: :ok
  end

  def create
    product_item_ids = @current_user.orders.joins(:order_items).pluck(:product_item_id)
    
    unless product_item_ids.include?(params[:product_item_id].to_i)
      return render json: { error: "Unable to create review" }, status: :unprocessable_entity
    end

    product = ProductItem.find(params[:product_item_id]).product
    @review = product.reviews.build(reviews_params.merge(user: @current_user))

    if @review.save
      render json: ReviewSerializer.new(@review).serializable_hash, status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @review.update(reviews_params)
      render json: ReviewSerializer.new(@review).serializable_hash, status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: ReviewSerializer.new(@review).serializable_hash, status: :ok
  end

  private

  def reviews_params
    params.require(:review).permit(:title, :description, :rating, images_attributes: [:id, :image, :_destroy])
  end

  def set_review
    @review = @current_user.reviews.find_by(id: params[:id])
    unless @review
      render json: { error: "Unable to find review" }, status: :unprocessable_entity
    end
  end
end

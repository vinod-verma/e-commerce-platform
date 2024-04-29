class LikesController < ApplicationController
  before_action :authorize_request
  before_action :set_likeable
  before_action :is_liked

  def create
    if @like
      return render json: { error: "Unable to process this request." }, status: :unprocessable_entity
    end
    like = @likeable.likes.new(is_liked: like_params[:is_liked], user: @current_user)

    if like.save
      render_serialized_likeable(@likeable)
    else
      render_errors(like)
    end
  end

  def update
    if @like.update(is_liked: like_params[:is_liked])
      render_serialized_likeable(@likeable)
    else
      render_errors(@like)
    end
  end

  private

  def set_likeable
    if like_params[:product_answer_id]
      @likeable = ProductAnswer.find_by(id: like_params[:product_answer_id])
    elsif like_params[:review_id]
      @likeable = Review.find_by(id: like_params[:review_id])
    else
      return render json: { error: "Invalid parameters" }, status: :unprocessable_entity
    end

    render_not_found_error unless @likeable
  end

  def render_serialized_likeable(likeable)
    if likeable.is_a?(ProductAnswer)
      render json: ProductAnswerSerializer.new(likeable).serializable_hash, status: :ok
    elsif likeable.is_a?(Review)
      render json: ReviewSerializer.new(likeable).serializable_hash, status: :ok
    end
  end

  def render_errors(like)
    render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
  end

  def render_not_found_error
    return render json: { error: "Likeable object not found" }, status: :unprocessable_entity
  end

  def is_liked
    @like = @likeable.likes.find_by(user_id: @current_user.id)
  end

  def like_params
    params.require(:like).permit(:is_liked, :product_answer_id, :review_id)
  end
end

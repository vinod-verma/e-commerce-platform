 class ProductQuestionsController < ApplicationController
  before_action :authorize_request
  before_action :set_product_question, only: [:show, :update, :destroy]

  def index
    product_questions = Product.find(params[:product_id]).product_questions
    render json: ProductQuestionSerializer.new(product_questions).serializable_hash, status: :ok
  end

  def show
    render json: ProductQuestionSerializer.new(@product_question).serializable_hash, status: :ok
  end

  def create
    @product_question = @current_user.product_questions.new(product_question_params)

    if @product_question.save
      render json: ProductQuestionSerializer.new(@product_question).serializable_hash, status: :ok
    else
      render json: { errors: @product_question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @product_question.update(product_question_params)
      render json: ProductQuestionSerializer.new(@product_question).serializable_hash, status: :ok
    else
      render json: { errors: @product_question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @product_question.destroy
      render json: { message: "Product question removed from list." }, status: :ok
    else
      render json: { errors: @product_question.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private
    def set_product_question
      @product_question = @current_user.product_questions.find(params[:id])
      unless @product_question
        render json: { error: "Unable to find product question" }, status: :unprocessable_entity
      end
    end

    def product_question_params
      params.require(:product_question).permit(:question, :product_id)
    end
end

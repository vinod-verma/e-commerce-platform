 class ProductAnswersController < ApplicationController
  before_action :authorize_request
  before_action :set_product_answer, only: [:show, :update, :destroy]

  def index
    answers = ProductQuestion.find(params[:product_question_id]).product_answers
    render json: ProductAnswerSerializer.new(answers).serializable_hash, status: :ok
  end

  def show
    render json: ProductAnswerSerializer.new(@answer).serializable_hash, status: :ok
  end

  def create
    product_question = ProductQuestion.find(product_answer_params[:product_question_id])

    unless product_question
      return render json: { error: "Product question not found" }, status: :unprocessable_entity
    end
    product = product_question.product
    product_ids = @current_user.orders.joins(:product_items).pluck(:product_id)
    
    unless product_ids.include?(product.id)
      return render json: { error: "You are not eligible to post answer" }, status: :unprocessable_entity
    end

    if product_question.product_answers.find_by(user_id: @current_user.id)
      return render json: { error: "You have already posted an answer" }, status: :unprocessable_entity
    end
    @answer = product_question.product_answers.new(product_answer_params.merge(user: @current_user))

    if @answer.save
      render json: ProductQuestionSerializer.new(product_question).serializable_hash, status: :ok
    else
      render json: { errors: @answer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @answer.update(product_answer_params)
      render json: ProductAnswerSerializer.new(@answer).serializable_hash, status: :ok
    else
      render json: { errors: @answer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @answer.destroy
      render json: { message: "Product answer deleted." }, status: :ok
    else
      render json: { errors: @answer.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private
    def set_product_answer
      @answer =  @current_user.product_answers.find(params[:id])
      unless @answer
        render json: { error: "Unable to find answer" }, status: :unprocessable_entity
      end
    end

    def product_answer_params
      params.require(:product_answer).permit(:answer, :product_question_id)
    end
end

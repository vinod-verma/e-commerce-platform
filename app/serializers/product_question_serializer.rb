class ProductQuestionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :question, :product_id, :user_id, :created_at, :updated_at

  attribute :answer do |question|
    ProductAnswerSerializer.new(question.product_answers).serializable_hash
  end
end
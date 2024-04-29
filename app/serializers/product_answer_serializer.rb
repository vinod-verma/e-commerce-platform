class ProductAnswerSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :answer, :product_question_id, :user_id, :created_at, :updated_at

  attribute :likes_count do |product_answer|
    product_answer.likes.group(:is_liked).count[true]
  end

  attribute :dislike_count do |product_answer|
    product_answer.likes.group(:is_liked).count[false]
  end
end
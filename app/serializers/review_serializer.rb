class ReviewSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :rating, :title, :description

  attribute :images do |review|
    ImageSerializer.new(review.images).serializable_hash
  end

  attribute :likes_count do |review|
    review.likes.group(:is_liked).count[true]
  end

  attribute :dislike_count do |review|
    review.likes.group(:is_liked).count[false]
  end
end
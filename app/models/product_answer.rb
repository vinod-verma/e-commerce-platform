class ProductAnswer < ApplicationRecord
  belongs_to :user
  belongs_to :product_question
  has_many :likes, as: :likeable
  validates :answer, presence: true
end

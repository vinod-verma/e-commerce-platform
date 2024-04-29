class ProductQuestion < ApplicationRecord
  belongs_to :user
  belongs_to :product
  has_many :product_answers, dependent: :destroy
  validates :question, presence: true
end

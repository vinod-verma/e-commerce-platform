class Product < ApplicationRecord
  belongs_to :category
  belongs_to :manufacturer
  has_many :product_items
  has_many :product_questions
  validates :name, :description, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "name", "updated_at"]
  end
  has_many :reviews, as: :reviewable
end

class Category < ApplicationRecord
  has_many :categories, class_name: "Category",
                          foreign_key: "parent_category_id"
  has_many :options, dependent: :destroy
  accepts_nested_attributes_for :options, allow_destroy: true
  has_many :category_offers
  has_many :category_attributes, dependent: :destroy
  accepts_nested_attributes_for :category_attributes, allow_destroy: true

  belongs_to :parent_category, class_name: "Category", optional: true
  validates :category_name, presence: true, uniqueness: { scope: :parent_category_id }

  def self.ransackable_attributes(auth_object = nil)
    ["category_name", "created_at", "id", "parent_category_id", "updated_at"]
  end

end

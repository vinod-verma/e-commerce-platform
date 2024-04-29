class CategoryAttribute < ApplicationRecord
  self.table_name = :attribute_names

  belongs_to :category
  has_many :product_attributes
  validates :attr_name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["attr_name", "category_id", "created_at", "id", "updated_at"]
  end
end

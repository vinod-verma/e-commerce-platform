class ProductAttribute < ApplicationRecord
  belongs_to :category_attribute, foreign_key: 'attribute_name_id'
  belongs_to :product_item
  validates :attr_value, presence: true
end

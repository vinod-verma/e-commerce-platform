class ProductItem < ApplicationRecord
  belongs_to :product
  belongs_to :variation_option
  validates :sku, :qty_in_stock, :price, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "price", "product_id", "qty_in_stock", "sku", "updated_at", "variation_option_id"]
  end

  has_many :product_attributes, dependent: :destroy
  accepts_nested_attributes_for :product_attributes, allow_destroy: true
  has_many :product_suppliers, dependent: :destroy
  accepts_nested_attributes_for :product_suppliers, allow_destroy: true
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
end

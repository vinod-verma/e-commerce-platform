class ProductSupplier < ApplicationRecord
  belongs_to :product_item
  belongs_to :supplier
end

class ProductSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :description

  attribute :category do |product|
    product.category&.category_name
  end

  attribute :manufacturer do |product|
    product.manufacturer&.name
  end
end
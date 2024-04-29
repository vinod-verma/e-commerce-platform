class ProductItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :price, :sku

  attribute :produc do |product_item|
    ProductSerializer.new(product_item.product).serializable_hash
  end

  attribute :images do |product_item|
    ImageSerializer.new(product_item.images).serializable_hash
  end

  attribute :product_attributes do |product_item|
    ProductAttributeSerializer.new(product_item.product_attributes).serializable_hash
  end
end
class ProductAttributeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :attr_value

  attribute :attr_name do |pr_attr|
    pr_attr.category_attribute&.attr_name
  end
end
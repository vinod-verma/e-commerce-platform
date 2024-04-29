class CategorySerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :category_name
end
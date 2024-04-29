class ImageSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :image_url, :rank
end
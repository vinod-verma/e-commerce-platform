class AddressSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :phone, :pincode, :locality, :address, :city, :state, :landmark, :alt_phone, :address_type
end
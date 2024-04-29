class Address < ApplicationRecord
  belongs_to :user
  validates :name, :phone, :pincode, :locality, :address, :city, :state, :landmark, presence: true
end

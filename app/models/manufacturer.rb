class Manufacturer < ApplicationRecord
  has_many :products, dependent: :destroy
  validates :name, :location, :contact_info, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end

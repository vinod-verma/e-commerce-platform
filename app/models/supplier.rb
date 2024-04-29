class Supplier < ApplicationRecord
  has_many :product_suppliers, dependent: :destroy
  validates :name, :location, :contact_info, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end

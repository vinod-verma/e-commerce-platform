class CategoryOffer < ApplicationRecord
  belongs_to :category
  belongs_to :offer

  def self.ransackable_associations(auth_object = nil)
    ["category", "offer"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "offer_id", "updated_at"]
  end
end

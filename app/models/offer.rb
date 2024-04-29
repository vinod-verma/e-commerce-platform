class Offer < ApplicationRecord
  has_many :category_offers, dependent: :destroy
  validates :name, :description, :discount, :start_date, :end_date, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["name"]
  end
end

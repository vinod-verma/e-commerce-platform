class VariationOption < ApplicationRecord
  belongs_to :option
  has_many :product_items
  validates :value, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "option_id", "updated_at", "value"]
  end
end

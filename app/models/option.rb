class Option < ApplicationRecord
  belongs_to :category
  has_many :variation_options, dependent: :destroy
  accepts_nested_attributes_for :variation_options, allow_destroy: true

  validates :option_name, presence: true, uniqueness: { scope: :category_id }

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "option_name", "updated_at"]
  end
end

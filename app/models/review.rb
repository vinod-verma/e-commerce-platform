class Review < ApplicationRecord
  belongs_to :reviewable, polymorphic: true
  belongs_to :user
  has_many :images, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true
  validates :description, :rating, presence: true
  has_many :likes, as: :likeable
end

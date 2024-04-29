class Like < ApplicationRecord
  belongs_to :likeable, polymorphic: true
  belongs_to :user
  validates :is_liked, inclusion: [true, false]
end

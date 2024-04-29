class User < ApplicationRecord
  has_secure_password
  has_one_attached :image

  has_many :reviews
  has_one :cart, dependent: :destroy
  has_one :wish_list, dependent: :destroy
  has_many :addresses
  has_many :orders
  has_many :product_questions
  has_many :product_answers
  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            length: { minimum: 6 },
            if: -> { new_record? || !password.nil? }

  def all_product_item_ids
    OrderItem.joins(order: :user)
             .where('users.id = ?', self.id)
             .pluck(:product_item_id)
  end
end

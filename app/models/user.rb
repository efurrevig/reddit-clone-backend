class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :subscriptions, foreign_key: :user_id, class_name: 'Subscriber'
  has_many :communities, through: :subscriptions
  has_many :posts
  has_many :comments
end
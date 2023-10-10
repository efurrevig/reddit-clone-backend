# Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  username               :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  jti                    :string           not null
#  avatar_key             :string

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :subscriptions, foreign_key: :user_id, class_name: 'Subscriber'
  has_many :communities, through: :subscriptions
  has_many :posts
  has_many :comments
  has_many :votes

  validates :username, uniqueness: true, presence: true
end
class Subscriber < ApplicationRecord
  belongs_to :user
  belongs_to :community

  enum :status, [:member, :approved, :moderator, :banned]

  validates :user_id, uniqueness: { scope: :community_id, message: "has already subscribed to community" }
end

class Subscriber < ApplicationRecord
  belongs_to :user
  belongs_to :community
                #   0         1           2         3       4
  enum :status, [:member, :approved, :moderator, :admin, :banned]
  validates :user_id, uniqueness: { scope: :community_id, message: "has already subscribed to community" }
end


#### VALIDATE ENUM STATUS
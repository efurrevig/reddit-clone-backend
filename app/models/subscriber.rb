class Subscriber < ApplicationRecord
  belongs_to :user
  belongs_to :community

  enum :status, [:member, :approved, :moderator, :banned]
end

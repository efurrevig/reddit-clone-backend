class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community

  has_many :comments

  enum post_type: [ :message, :media ]

  validates :media_url, presence: true, if: -> { media? }
  validates :body, presence: true, if: -> { message? }
end

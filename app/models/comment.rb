class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_many :comments, as: :commentable

  validates :body, presence: true
  validates :user_id, presence: true

  validates :commentable_type, presence: true, inclusion: { in: %w(Post Comment) }
  validates :commentable, presence: true

end

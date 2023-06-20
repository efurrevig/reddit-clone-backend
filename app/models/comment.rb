class Comment < ApplicationRecord
  belongs_to :users
  belongs_to :posts
  belongs_to :parent_comment, class_name: 'Comment', optional: true

  has_many :child_comments, class_name: 'Comment', foreign_key: 'parent_comment_id'

  validates :body, presence: true
end

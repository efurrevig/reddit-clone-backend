class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post
  belongs_to :parent_comment, class_name: 'Comment', optional: true

  has_many :child_comments, class_name: 'Comment', foreign_key: 'parent_comment_id'

  validates :body, presence: true
  validates :user_id, presence: true
  validates :post_id, presence: true
  validate :parent_comment_exists_on_same_post, if: -> { parent_comment_id }

  private

  def parent_comment_exists_on_same_post
    unless post.comments.exists?(id: parent_comment_id)
      errors.add(:parent_comment_id, "must be associated with an existing comment on the same post")
    end
  end
end

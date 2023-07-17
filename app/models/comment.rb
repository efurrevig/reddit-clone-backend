# Schema Information
#
# Table name: comments
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint           not null
#  commentable_type      :string           not null
#  commentable_id        :bigint           not null
#  body                  :text             not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  like_count            :integer          default(0), not null
#  comment_count         :integer          default(0), not null
#

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_many :votes, as: :votable
  has_many :comments, as: :commentable

  validates :body, presence: true
  validates :user_id, presence: true

  validates :commentable_type, presence: true, inclusion: { in: %w(Post Comment) }
  validates :commentable, presence: true
  
  after_create :increment_commentable_comment_count


  def update_vote_count(value)
    self.vote_count += value
    self.save!
  end

  def update_comment_count(value)
    self.comment_count += value
    self.save!
  end

  # if comment created, updates comment_count on commentable
  #     if commentable is a comment, also updates comment_count on root post
  # if comment deleted, updates comment_count on commentable
  # may move to controller
  def increment_commentable_comment_count
    if self.commentable_type == "Post"
      commentable.update_comment_count(1)
    else
      root = Post.find(commentable.root_id)
      root.update_comment_count(1)
      commentable.update_comment_count(1)
    end
  end


end

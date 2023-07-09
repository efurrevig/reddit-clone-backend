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
  
  def update_vote_count(value)
    self.vote_count += value
    self.save!
  end

end

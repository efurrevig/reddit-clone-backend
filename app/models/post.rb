# Schema Information
#
# Table name: posts
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint           not null
#  community_id       :bigint           not null
#  post_type          :integer          default( 0: "message" ), not null
#  title              :string           not null
#  body               :text
#  media_url          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_deleted?        :boolean          default(FALSE)
#  like_count         :integer          default(0), not null
#


class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  
  has_many :votes, as: :votable
  has_many :comments, as: :commentable

  enum post_type: [ :message, :media ]

  validates :media_url, presence: true, if: -> { media? }
  validates :body, presence: true, if: -> { message? }

  def update_vote_count(value)
    self.vote_count += value
    self.save!
  end

  def self.fetch_posts_without_user(sorted_by, community_id, page = nil)
    case sorted_by
    when 'hot'
      return Post
        .select('posts.*')
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    when 'new'
      return Post
        .select('posts.*')
        .where('posts.community_id = ?', community_id)
        .order('posts.created_at DESC')
    when 'top'
      return Post
        .select('posts.*')
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    else
      return Post
        .select('posts.*')
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    end
  end

  def self.fetch_posts_with_user(sorted_by, community_id, user_id = nil, page = nil)
    case sorted_by
    when 'hot'
      return Post
        .joins(:votes)
        .select('posts.*, votes.value as vote_value')
        .where('posts.community_id = ? AND posts.id = votes.votable_id AND votes.user_id = ?', community_id, user_id)
        .order('posts.vote_count DESC')
    when 'new'
      return Post
        .joins(:votes)
        .select('posts.*, votes.value as vote_value')
        .where('posts.community_id = ? AND posts.id = votes.votable_id AND votes.user_id = ?', community_id, user_id)
        .order('posts.created_at DESC')
    when 'top'
      return Post
        .joins(:votes)
        .select('posts.*, votes.value as vote_value')
        .where('posts.community_id = ? AND posts.id = votes.votable_id AND votes.user_id = ?', community_id, user_id)
        .order('posts.vote_count DESC')
    else
      return Post
        .select('posts.*')
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    end
  end
end

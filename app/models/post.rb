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

  def self.fetch_posts_with_user(sorted_by, community_id, user_id, page = nil)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table

    vote_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(posts_table[:id]).and(votes_table[:user_id].eq(user_id))
    ))
    case sorted_by
    when 'hot'
      return Post.joins(vote_join.to_sql)
        .where(community_id: community_id)
        .select('posts.*, votes.value as vote_value')
        .order('posts.vote_count DESC')
    when 'new'
      return Post.joins(vote_join.to_sql)
        .where(community_id: community_id)
        .select('posts.*, votes.value as vote_value')
        .order('posts.vote_count DESC')
        .order('posts.created_at DESC')
    when 'top'
      return Post.joins(vote_join.to_sql)
        .where(community_id: community_id)
        .select('posts.*, votes.value as vote_value')
        .order('posts.vote_count DESC')
        .order('posts.vote_count DESC')
    else
      return Post.joins(vote_join.to_sql)
        .where(community_id: community_id)
        .select('posts.*, votes.value as vote_value')
        .order('posts.vote_count DESC')
    end
  end
end




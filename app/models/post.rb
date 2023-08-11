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
#  vote_count         :integer          default(0), not null
#  comment_count      :integer          default(0), not null
#


class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  
  has_many :votes, as: :votable
  has_many :comments, as: :commentable

  enum post_type: [ :message, :media, :url ]

  validates :url, presence: true, if: -> { url? }
  validates :body, presence: true, if: -> { message? }



  def update_vote_count(value)
    self.vote_count += value
    self.save!
  end

  def update_score(value)
    self.score = [get_score_value(value)+self.score, 0].max
    self.save!
  end

  def update_comment_count(value)
    self.comment_count += value
    self.save!
  end

  def epoch_date(date)
    td = Time.now - date
    return td.days * 86400 + td.seconds
  end

  def time_degree(time)
    some_const = (10**(-16) * time).to_f
    return (1 + Math.exp(-some_const)).round(7)
  end

  def like_degree(likes)
    some_const = 0.1 * likes
    return 1 + (999 * Math.exp(-some_const)).round(7)
  end
  #value of votes is higher when the post is newer and has less votes. the first vote is worth 
  def get_score_value(value)
    time = epoch_date(self.created_at) - 1134028003
    time_degree = time_degree(time)
    likes = self.vote_count + value
    like_degree = like_degree(likes)
    return (time_degree * like_degree).round(7) * value
  end


  # NOT LOGGED IN, returns posts for a community
  def self.fetch_posts_without_user(sorted_by, community_id, page = nil)
    case sorted_by
    when 'hot'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    when 'new'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where('posts.community_id = ?', community_id)
        .order('posts.created_at DESC')
    when 'top'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    else
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where('posts.community_id = ?', community_id)
        .order('posts.vote_count DESC')
    end
  end

  # LOGGED IN returns posts for a community with the vote value (if any) for a user
  def self.fetch_posts_with_user(sorted_by, community_id, user_id, page = nil)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table

    vote_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(posts_table[:id])
          .and(votes_table[:user_id].eq(user_id))
          .and(votes_table[:votable_type].eq("Post"))
    ))
    case sorted_by
    when 'hot'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id)
        .order('posts.vote_count DESC')
    when 'new'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id)
        .order('posts.created_at DESC')
    when 'top'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id)
        .order('posts.vote_count DESC')
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id)
        .order('posts.vote_count DESC')
    end
  end

  # LOGGED IN returns the posts for a user's subscribed communities with the vote value (if any) for the user
  def self.fetch_home_posts_with_user(sorted_by, user_id, page = nil)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table
    subscriber_table = Subscriber.arel_table

    sub_join = Arel::Nodes::InnerJoin.new(
      subscriber_table,
      Arel::Nodes::On.new(
        subscriber_table[:community_id].eq(posts_table[:community_id])
        .and(subscriber_table[:user_id].eq(user_id))
      )
    )
    vote_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(posts_table[:id])
          .and(votes_table[:user_id].eq(user_id))
          .and(votes_table[:votable_type].eq("Post"))
      )
    )
    case sorted_by
    when 'hot'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .order('posts.vote_count DESC')
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .order('posts.vote_count DESC')
    end
  end

  # NOT LOGGED IN returns all posts
  def self.fetch_home_posts_without_user(sorted_by, page = nil)
    case sorted_by
    when 'hot'
      return Post.select('posts.*, communities.name as community_name, users.username as author').joins(:community, :user).order('posts.vote_count DESC').limit(30)
    else
      return Post.order('posts.vote_count DESC').limit(30)
    end
  end

  def self.fetch_popular_posts_with_user(sorted_by, user_id)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table
    subscriber_table = Subscriber.arel_table

    votes_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(posts_table[:id])
          .and(votes_table[:user_id].eq(user_id))
          .and(votes_table[:votable_type].eq("Post"))
      )
    )
    subs_join = Arel::Nodes::OuterJoin.new(
      subscriber_table,
      Arel::Nodes::On.new(
        subscriber_table[:community_id].eq(posts_table[:community_id])
          .and(subscriber_table[:user_id].eq(user_id))
      )
    )
    case sorted_by
    when 'top'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author, subscribers.status as subscription_status')
        .joins(votes_join.to_sql)
        .joins(subs_join.to_sql)
        .joins(:community, :user)
        .order('posts.vote_count DESC')
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author, subscribers.status as subscription_status')
        .joins(votes_join.to_sql)
        .joins(subs_join.to_sql)
        .joins(:community, :user)
        .order('posts.vote_count DESC')
    end
  end

  def get_post_comments_without_user(sorted_by)
    case sorted_by
    when 'top'
      return Comment.select('comments.*, users.username as author')
        .joins(:user)
        .where(root_id: self.id)
        .order('depth ASC, vote_count DESC')
    else 
      return Comment.select('comments.*, users.username as author')
        .joins(:user)
        .where(root_id: self.id)
        .order('depth ASC, vote_count DESC')
    end
  end

  def get_post_comments_with_user(sorted_by, user_id)
    comments_table = Comment.arel_table
    votes_table = Vote.arel_table
    votes_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(comments_table[:id])
          .and(votes_table[:user_id].eq(user_id))
          .and(votes_table[:votable_type].eq("Comment"))
      )
    )
    case sorted_by
    when 'top'
      return Comment.select('comments.*, users.username as author, votes.value as vote_value')
        .joins(:user)
        .joins(votes_join.to_sql)
        .where(root_id: self.id)
        .order('depth ASC, vote_count ASC')
    else 
      return Comment.select('comments.*, users.username as author, votes.value as vote_value')
        .joins(:user)
        .joins(votes_join.to_sql)
        .where(root_id: self.id)
        .order('depth ASC, vote_count ASC')
    end
  end

  def self.fetch_post_with_user(post_id, user_id)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table
    vote_join = Arel::Nodes::OuterJoin.new(
      votes_table,
      Arel::Nodes::On.new(
        votes_table[:votable_id].eq(posts_table[:id])
          .and(votes_table[:user_id].eq(user_id))
          .and(votes_table[:votable_type].eq("Post"))
      )
    )
    return Post.select('posts.*, votes.value as vote_value, users.username as author')
      .joins(vote_join.to_sql)
      .joins(:user)
      .where(id: post_id)
      .first
  end



end
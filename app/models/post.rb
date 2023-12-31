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
#  url                :string
#  media_key          :string           
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

  validate :validate_attributes_based_on_post_type



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
  def self.fetch_community_posts_without_user(sorted_by, community_id, page = 1)
    offset = (page-1) * 10
    case sorted_by
    when 'hot'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.score DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    when 'new'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.created_at DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    when 'top'
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.vote_count DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    else
      return Post
        .select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.score DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    end
  end

  # LOGGED IN returns posts for a community with the vote value (if any) for a user


  def self.fetch_community_posts_with_user(sorted_by, community_id, user_id, page = 1)
    offset = (page-1) * 10
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
    case sorted_by
    when 'hot'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.score DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    when 'new'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.created_at DESC')
        .limit(10)
        .offset(offset)
    when 'top'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.vote_count DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(community_id: community_id, is_deleted: false)
        .order('posts.vote_count DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    end
  end

  # LOGGED IN returns the posts for a user's subscribed communities with the vote value (if any) for the user
  def self.fetch_home_posts_with_user(sorted_by, user_id, page = 1)
    offset = (page-1) * 10
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
        # .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    when 'new'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        # .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.created_at DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    when 'top'
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        # .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.vote_count DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author')
        # .joins(sub_join.to_sql)
        .joins(vote_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC, posts.id DESC')
        .limit(10)
        .offset(offset)
    end
  end

  # NOT LOGGED IN returns all posts
  def self.fetch_home_posts_without_user(sorted_by, page = 1)
    offset = (page-1)*10
    case sorted_by
    when 'hot'
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(10)
        .offset(offset)
    else
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(10)
        .offset(offset)
    end
  end

  def self.fetch_popular_posts_with_user(sorted_by, user_id, page = 1)

    posts_table = Post.arel_table
    votes_table = Vote.arel_table
    subscriber_table = Subscriber.arel_table
    offset = (page-1)*20

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
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(20)
        .offset(offset)
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author, subscribers.status as subscription_status')
        .joins(votes_join.to_sql)
        .joins(subs_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(20)
        .offset(offset)
    end
  end

  def self.fetch_popular_posts_without_user(sorted_by, page = 1)
    offset = (page-1)*10
    case sorted_by
    when 'hot'
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(20)
        .offset(offset)
    else
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.score DESC')
        .limit(20)
        .offset(offset)
    end
  end

  def self.fetch_all_posts_without_user(sorted_by, page = 1)
    offset = (page-1)*10
    case sorted_by
    when 'hot'
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.created_at DESC')
        .limit(20)
        .offset(offset)
    else
      return Post.select('posts.*, communities.name as community_name, users.username as author')
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.created_at DESC')
        .limit(20)
        .offset(offset)
    end
  end

  def self.fetch_all_posts_with_user(sorted_by, user_id, page = 1)
    posts_table = Post.arel_table
    votes_table = Vote.arel_table
    subscriber_table = Subscriber.arel_table
    offset = (page-1)*20

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
        .where(is_deleted: false)
        .order('posts.created_at DESC')
        .limit(20)
        .offset(offset)
    else
      return Post.select('posts.*, votes.value as vote_value, communities.name as community_name, users.username as author, subscribers.status as subscription_status')
        .joins(votes_join.to_sql)
        .joins(subs_join.to_sql)
        .joins(:community, :user)
        .where(is_deleted: false)
        .order('posts.created_at DESC')
        .limit(20)
        .offset(offset)
    end

  end

  def get_post_comments_without_user(sorted_by)
    select_string = 'comments.*, users.username as author, users.avatar_key as user_avatar_key'
    case sorted_by
    when 'top'
      return Comment.select(select_string)
        .joins(:user)
        .where(root_id: self.id)
        .order('depth ASC, vote_count DESC')
    when 'new'
      return Comment.select(select_string)
        .joins(:user)
        .where(root_id: self.id)
        .order('depth ASC, created_at DESC')
    else 
      return Comment.select(select_string)
        .joins(:user)
        .where(root_id: self.id)
        .order('depth ASC, vote_count DESC')
    end
  end

  def get_post_comments_with_user(sorted_by, user_id)
    select_string = 'comments.*, users.username as author, votes.value as vote_value, users.avatar_key as user_avatar_key'
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
      return Comment.select(select_string)
        .joins(:user)
        .joins(votes_join.to_sql)
        .where(root_id: self.id)
        .order('depth ASC, vote_count ASC')
    when 'new'
      return Comment.select(select_string)
        .joins(:user)
        .joins(votes_join.to_sql)
        .where(root_id: self.id)
        .order('depth ASC, created_at DESC')
    else 
      return Comment.select(select_string)
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

  private

  def validate_attributes_based_on_post_type
    case post_type.to_sym
    when :message
      validate_presence_of_body
    when :media
      validate_presence_of_media_key
    when :url
      validate_presence_of_url
    end
  end

  def validate_presence_of_body
    if body.blank?
      errors.add(:body, "can't be blank")
    end
  end

  def validate_presence_of_media_key
    if media_key.blank?
      errors.add(:media_key, "can't be blank")
    end
  end

  def validate_presence_of_url
    if url.blank?
      errors.add(:url, "can't be blank")
    end
  end

end

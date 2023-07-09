class AddLikeCountToCommentsPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :vote_count, :integer, default: 0, null: false
    add_column :posts, :vote_count, :integer, default: 0, null: false
  end
end

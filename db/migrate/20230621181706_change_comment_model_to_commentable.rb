class ChangeCommentModelToCommentable < ActiveRecord::Migration[7.0]
  def change
    remove_column :comments, :parent_comment_id, :integer
    add_reference :comments, :commentable, polymorphic: true, index: true
  end
end

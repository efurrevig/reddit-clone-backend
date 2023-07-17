class RemoveCommentCountFromComments < ActiveRecord::Migration[7.0]
  def change
    remove_column :comments, :comment_count
  end
end

class ChangePostsDeletedToIsDeleted < ActiveRecord::Migration[7.0]
  def change
    rename_column :posts, :deleted, :is_deleted?
  end
end

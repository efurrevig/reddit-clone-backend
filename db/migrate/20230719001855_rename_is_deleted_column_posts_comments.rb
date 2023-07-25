class RenameIsDeletedColumnPostsComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :posts, :is_deleted?, :is_deleted
    rename_column :comments, :is_deleted?, :is_deleted
  end
end

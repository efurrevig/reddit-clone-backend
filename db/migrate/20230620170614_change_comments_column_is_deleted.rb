class ChangeCommentsColumnIsDeleted < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :is_deleted, :is_deleted?
  end
end

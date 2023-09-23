class FixCommentsReferences < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :users_id, :user_id
  end
end

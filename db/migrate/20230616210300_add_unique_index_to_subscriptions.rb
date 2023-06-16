class AddUniqueIndexToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_index :subscribers, [:user_id, :community_id], unique: true
  end
end

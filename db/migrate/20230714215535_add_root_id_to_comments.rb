class AddRootIdToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :root_id, :bigint, null: true
  end
end

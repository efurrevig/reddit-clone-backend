class AddRootIndexAndDepthToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :depth, :integer, default: 0
    add_index :comments, :root_id
  end
end

class CreateIndexOnCreatedAt < ActiveRecord::Migration[7.0]
  def change
    add_index :posts, :created_at
  end
end

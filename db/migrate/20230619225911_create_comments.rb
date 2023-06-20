class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :users, null: false, foreign_key: true
      t.references :posts, null: false, foreign_key: true
      t.integer :parent_comment_id, foreign_key: { to_table: :comments }
      t.text :body, null: false
      t.boolean :is_deleted, null: false, default: false

      t.timestamps
    end
  end
end

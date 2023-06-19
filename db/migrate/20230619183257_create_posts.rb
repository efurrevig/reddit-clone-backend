class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.integer :post_type, null: false, default: 0
      t.string :title, null: false
      t.text :body
      t.string :media_url

      t.timestamps
    end
  end
end

class AddScoreColumnToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :score, :integer, default: 0, null: false
    add_index :posts, :score
  end
end

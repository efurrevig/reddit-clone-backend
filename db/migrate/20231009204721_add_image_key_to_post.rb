class AddImageKeyToPost < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :media_key, :string
  end
end

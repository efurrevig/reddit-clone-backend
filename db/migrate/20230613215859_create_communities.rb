class CreateCommunities < ActiveRecord::Migration[7.0]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :communities, :name, unique: true
  end
end

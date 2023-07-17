class AddDescriptionToCommunity < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :description, :text, null: false, default: ''
  end
end

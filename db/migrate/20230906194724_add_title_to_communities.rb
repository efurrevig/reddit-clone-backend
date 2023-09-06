class AddTitleToCommunities < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :title, :string
  end

end

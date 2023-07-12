class ChangePostColumnMediaUrlToUrl < ActiveRecord::Migration[7.0]
  def change
    rename_column :posts, :media_url, :url
  end
end

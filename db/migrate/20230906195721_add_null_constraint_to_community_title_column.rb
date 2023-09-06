class AddNullConstraintToCommunityTitleColumn < ActiveRecord::Migration[7.0]
  def change
    change_column_null :communities, :title, true
  end
end

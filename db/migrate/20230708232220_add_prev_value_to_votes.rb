class AddPrevValueToVotes < ActiveRecord::Migration[7.0]
  def change
    add_column :votes, :prev_value, :integer, default: 0, null: false
    change_column_default :votes, :value, 0
  end
end

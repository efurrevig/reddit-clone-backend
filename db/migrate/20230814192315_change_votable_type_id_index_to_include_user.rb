class ChangeVotableTypeIdIndexToIncludeUser < ActiveRecord::Migration[7.0]
  def change
    remove_index :votes, name: 'index_votes_on_votable'

    add_index :votes, ["votable_type", "votable_id", "user_id"], name: "index_votes_on_votable", unique: true
  end
end

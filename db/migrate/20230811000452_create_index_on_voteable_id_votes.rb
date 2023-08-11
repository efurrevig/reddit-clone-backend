class CreateIndexOnVoteableIdVotes < ActiveRecord::Migration[7.0]
  def change
    add_index :votes, :votable_id
  end
end

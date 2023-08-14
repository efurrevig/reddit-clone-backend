class CreateVotesIndexOnUserId < ActiveRecord::Migration[7.0]
  def change
    add_index :votes, ["user_id"], name: "index_votes_on_user_id"
  end
end

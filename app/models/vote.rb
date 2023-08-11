# Schema Information
#
# Table name: votes
#
#  id               :bigint           not null, primary key
#  user_id          :bigint           not null
#  votable_type     :string           not null
#  votable_id       :bigint           not null
#  value            :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Vote < ApplicationRecord
    belongs_to :user
    belongs_to :votable, polymorphic: true

    validates :user_id, uniqueness: { scope: [:votable_type, :votable_id] }
    validates :value, presence: true, inclusion: { in: [-1, 0, 1] }

    after_create :update_votable
    after_update :update_votable

    def update_votable
        change = self.value == 0 ? self.prev_value*-1 : self.value - self.prev_value
        votable.update_vote_count(change)
        if votable.is_a?(Post)
            votable.update_score(change)
        end
    end
end

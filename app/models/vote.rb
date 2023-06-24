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
end

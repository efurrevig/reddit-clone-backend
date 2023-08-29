# Schema Information
#
# Table name: subscribers
#
#  id                :bigint           not null, primary key
#  user_id           :bigint           not null
#  community_id      :bigint           not null
#  status            :integer          default( 0: "member" ), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null


class Subscriber < ApplicationRecord
  belongs_to :user
  belongs_to :community
                #   0         1           2         3       4
  enum :status, [:member, :approved, :moderator, :admin, :banned]
  validates :user_id, uniqueness: { scope: :community_id, message: "has already subscribed to community" }


end


#### VALIDATE ENUM STATUS
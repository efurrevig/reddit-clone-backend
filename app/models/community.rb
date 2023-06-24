# Schema Information
#
# Table name: community
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Community < ApplicationRecord
    validates :name, length: { minimum: 3 }

    has_many :subscribers
    has_many :posts
end

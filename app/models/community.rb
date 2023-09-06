# Schema Information
#
# Table name: community
#
#  id               :bigint           not null, primary key
#  name             :string           not null
#  description      :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  title            :string           not null
#

class Community < ApplicationRecord
    validates :name, length: { minimum: 3 }
    validates :name, uniqueness: true
    validates :title, presence: true

    has_many :subscribers
    has_many :posts

end

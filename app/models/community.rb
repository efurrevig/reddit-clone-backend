class Community < ApplicationRecord
    validates :name, length: { minimum: 3 }

    has_many :subscribers
    has_many :posts
end

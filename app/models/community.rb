class Community < ApplicationRecord
    validates :name, length: { minimum: 3 }

    has_many :subscribers
end

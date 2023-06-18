FactoryBot.define do
    factory :user do
        username { Faker::Lorem.characters(number: 15, min_alpha: 15) }
        email { Faker::Internet.email }
        password { Faker::Internet.password }
    end
end
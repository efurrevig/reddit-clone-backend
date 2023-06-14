FactoryBot.define do
    factory :user do
        username { Faker::Lorem.word }
        email { Faker::Internet.email }
        password { Faker::Internet.password }
    end
end
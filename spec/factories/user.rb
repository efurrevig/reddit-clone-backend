FactoryBot.define do
    factory :user do
        username { Faker::Lorem.unique.word }
        email { Faker::Internet.unique.email }
        password { Faker::Internet.password }
    end
end
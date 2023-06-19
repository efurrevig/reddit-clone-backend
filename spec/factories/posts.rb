FactoryBot.define do
  factory :post do
    association :user
    association :community
    title { Faker::Lorem.characters(number: 20) }
    body { Faker::Lorem.characters(number: 50) }
  end
end

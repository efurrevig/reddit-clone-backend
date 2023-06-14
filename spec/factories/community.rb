FactoryBot.define do
    factory :community do
      name { Faker::Lorem.characters(number: 10, min_alpha: 10) }
    end
end
FactoryBot.define do
    factory :community do
      name { Faker::Lorem.characters(number: 15, min_alpha: 15) }
    end
end
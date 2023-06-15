FactoryBot.define do
  factory :subscriber do
    association :user
    association :community
  end
end

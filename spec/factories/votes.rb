FactoryBot.define do
  factory :vote do
    association :user
    association :votable, factory: :post
    value { 1 }
    
  end
end

FactoryBot.define do
  factory :comment do
    association :user
    association :post
    body { Faker::Lorem.paragraph }
    parent_comment_id { nil }
  end
end


FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.paragraph }

    factory :comment_of_post do
      association :commentable, factory: :post
    end

    factory :comment_of_comment do
      association :commentable, factory: :comment
    end

  end
end


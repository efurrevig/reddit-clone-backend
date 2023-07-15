FactoryBot.define do
  factory :comment do

    #need to look at this
    body { Faker::Lorem.paragraph }
    association :user, factory: :user

    factory :comment_of_post do
      association :commentable, factory: :post
      root_id { commentable.id }
    end

    factory :comment_of_comment do
      association :commentable, factory: :comment
    end

  end
end


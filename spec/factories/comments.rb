FactoryBot.define do
  factory :comment do

    #need to look at this
    body { Faker::Lorem.paragraph }
    association :user, factory: :user

    factory :comment_of_post do
      association :commentable, factory: :post
      root_id { commentable.id }
      depth { 0 }
    end

    factory :comment_of_comment do
      association :commentable, factory: :comment
      root_id { commentable.root_id }
      depth { commentable.depth + 1 }
    end

  end
end


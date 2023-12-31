# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


# communities = []
# users = []
# posts = []

# 10.times do
#     communities << FactoryBot.create(:community, name: Faker::Creature::Animal.unique.name())
# end

# 10.times do
#     communities << FactoryBot.create(:community, name: Faker::Music.unique.genre)
# end

# 10.times do
#     communities << FactoryBot.create(:community, name: Faker::Games::Zelda.unique.game.delete(' '))
# end

# 10.times do
#     communities << FactoryBot.create(:community, name: Faker::Music.unique.instrument)
# end

# 10.times do
#     communities << FactoryBot.create(:community, name: Faker::Movies::LordOfTheRings.unique.character.delete(' '))
# end

# 20.times do
#     users << FactoryBot.create(:user)
# end

# users.each do |user|
#     communities.each do |community|
#         FactoryBot.create(:subscriber, user: user, community: community)
#         posts << FactoryBot.create(:post, user: user, community: community, title: Faker::Lorem.sentence(word_count: 3), body: Faker::Lorem.word)
#     end
# end


# users.each do |user|
#     posts.each do |post|
#         FactoryBot.create(:vote, user: user, votable: post, value: [-1, 1].sample)
#     end
# end

post = Post.find(1)
user = User.find(21)

comments = []

5.times do
    temp = []
    temp << Comment.create(
        user_id: user.id,
        commentable_type: 'Post',
        commentable_id: post.id,
        body: 'This is a comment',
        root_id: post.id,
        depth: 0
    )
    comments.each do |comment|
        temp << Comment.create(
            user_id: user.id,
            commentable_type: 'Comment',
            commentable_id: comment.id,
            body: 'This is a comment',
            root_id: post.id,
            depth: comment.depth + 1
        )
    end
    comments = temp
end
post = Post.find(1)
user = User.find(21)

comments = []

5.times do
    temp = []
    temp << Comment.create(
        user_id: user.id,
        commentable_type: 'Post',
        commentable_id: post.id,
        body: 'This is a comment'
        root_id: post.id
    )
    comments.each do |comment|
        temp << Comment.create(
            user_id: user.id,
            commentable_type: 'Comment',
            commentable_id: comment.id,
            body: 'This is a comment'
            root_id: post.id
        )
    end
    comments = temp
end
module CommentHelper

    def populate_post_with_comments(post, count)
        count.times do
            create(:comment, post: post)
        end
    end

    def populate_comment_with_comments

    end

    def create_comment_api(post, new_comment, user)
        request_url = "/api/posts/#{post.id}/comments"
        post request_url, params: {
            comment: {
                body: new_comment.body,
                user_id: user ? user.id : nil,
                parent_comment_id: new_comment.parent_comment_id
            }
        }, headers: user ? authenticated_header(user) : nil
    end

    def update_comment_api(comment, updated_body, user)
        request_url = "/api/comments/#{comment.id}"
        patch request_url, params: {
            comment: {
                body: updated_body
            }
        }, headers: user ? authenticated_header(user) : nil
    end

end
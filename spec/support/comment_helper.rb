module CommentHelper

    def populate_post_with_comments(post, count)
        count.times do
            create(:comment_of_post, commentable: post)
        end
    end

    def populate_comment_with_comments(comment, count)
        count.times do
            create(:comment_of_comment, commentable: comment)
        end
    end

    def create_comment_api(commentable, new_comment, user)
        request_url = "/api/#{commentable.class.to_s.downcase.pluralize}/#{commentable.id}/comments"
        post request_url, params: {
            comment: {
                body: new_comment.body,
                user_id: user ? user.id : nil,
                commentable_type: commentable.class.to_s,
                commentable_id: commentable.id
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
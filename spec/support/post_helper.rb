

module PostHelper

    def populate_community_with_posts(community, count)
        count.times do
            create(:post, community: community)
        end
    end

    def populate_user_with_posts(user, count)
        count.times do
            create(:post, user: user)
        end
    end

    def create_post_api(community, new_post, user)
        request_url = "/api/communities/#{community.id}/posts"
        post request_url, params: {
            post: {
                title: new_post.title,
                body: new_post.body,
                post_type: new_post.post_type,
                media_url: new_post.media_url,
                user_id: user ? user.id : nil
            }
        }, headers: user ? authenticated_header(user) : nil
    end

    def edit_post_api(community, original_post, edited_post, user)
        request_url = "/api/communities/#{community.id}/posts/#{original_post.id}"
        patch request_url, params: {
            post: {
                title: edited_post.title,
                body: edited_post.body,
                post_type: edited_post.post_type,
                media_url: edited_post.media_url,
            }
        }, headers: user ? authenticated_header(user) : nil
    end

end
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

end
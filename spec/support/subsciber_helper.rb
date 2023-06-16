require 'faker'
require 'factory_bot_rails'

module SubscriberHelper

    def subscribe_to_community(user, community, auth_header)
        post "/api/communities/#{community.id}/subscribers", params: {
            subscriber: {
                user_id: user.id
            }
        }, headers: auth_header
    end

end
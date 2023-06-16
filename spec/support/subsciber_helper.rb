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

    def unsubscribe_to_community(subscriber, community, auth_header)
        delete "/api/communities/#{community.id}/subscribers/#{subscriber.id}",
            headers: auth_header
    end

end
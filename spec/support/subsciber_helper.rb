require 'faker'
require 'factory_bot_rails'

module SubscriberHelper

    def subscribe_to_community(community, auth_header)
        post "/api/communities/#{community.id}/subscribers",
            headers: auth_header
    end

    def unsubscribe_to_community(subscriber, community, auth_header)
        delete "/api/communities/#{community.id}/subscribers/#{subscriber.id}",
            headers: auth_header
    end

    def change_sub_status(status, sub_to_change, community, auth_header)
        request_url = "/api/communities/#{community.id}/subscribers/#{sub_to_change.id}"
        patch request_url, params: {
            subscriber: {
                status: status
            }
        }, headers: auth_header
    end
end
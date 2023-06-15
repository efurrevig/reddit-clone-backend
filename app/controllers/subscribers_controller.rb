class SubscribersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy]

    def index
        @community = Community.find(params[:community_id])
        @subscribers_count = Subscriber.where(community_id: @community.id).count
        render json: {
            status: {
                code: 200
            },
            data: @subscribers_count
        }
    end
end

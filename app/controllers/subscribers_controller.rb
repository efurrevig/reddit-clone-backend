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

    def create
        @community = Community.find(params[:community_id])
        @subscriber = @community.subscribers.build(community_params)

        if current_user.id == community_params[:user_id].to_i && @subscriber.save
            render json: {
                status: {
                    code: 200,
                    message: "Successfully subscribed to #{@community.name}"
                }
            }
        else
            render json: {
                status: {
                    code: 422,
                    message: @subscriber.errors.messages
                }
            }, status: 422
        end
    end

    private
    def community_params
        params.require(:subscriber).permit(:user_id)
    end

end

class SubscribersController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy, :update]
    before_action :community_admin?, only: [:update]
    before_action :set_subscriber, only: [:update, :destroy]

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
        @subscriber = @community.subscribers.build(subscriber_params)

        if current_user.id == subscriber_params[:user_id].to_i && @subscriber.save
            render json: {
                status: {
                    code:  200,
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

    def update
        if @subscriber.update(status_params)
            render json: {
                status: {
                    code: 204,
                    message: 'status updated'
                }
            }, status: 204
        else
            render json: {
                status: {
                    code: 422,
                    message: @subscriber.errors
                }
            }, status: 422
        end

    end

    def destroy

        if @subscriber.user_id == current_user.id
            @subscriber.destroy
            render json: {
                status: {
                    code: 202,
                    message: 'has successfully unsubscribed'
                }
            }, status: 202
        else
            render json: {
                status: {
                    code: 401,
                    message: 'not authorized'
                }
            }, status: 401
        end


    end

    private
    def set_subscriber
        @subscriber = Subscriber.find(params[:id])
    end

    def subscriber_params
        params.require(:subscriber).permit(:user_id, :community_id)
    end

    def status_params
        params.require(:subscriber).permit(:status)
    end

    def community_admin?
        subscriber = Subscriber.find_by(user_id: current_user.id, community_id: params[:community_id])
        head 422 if !(subscriber.present? && subscriber.status == :admin)
    end

    def community_moderator?

    end

end

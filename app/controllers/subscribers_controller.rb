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
        community = Community.find(params[:community_id])
        subscriber = community.subscribers.build(user_id: current_user.id)

        if subscriber.save
            render json: {
                status: {
                    code:  200,
                    data: subscriber
                }, status: 200
            }
        else
            render json: {
                status: {
                    code: 422,
                    message: subscriber.errors.messages
                }
            }, status: 422
        end
    end

    def update
        if @subscriber.update(status: status_params[:status].to_i)
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
        params.require(:subscriber).permit(:community_id)
    end

    def status_params
        params.require(:subscriber).permit(:status)
    end

    def community_admin?
        subscriber = Subscriber.find_by(user_id: current_user.id, community_id: params[:community_id])
        head 422 if !(subscriber.present? && subscriber.status.to_sym == :admin)
    end

    def community_moderator?

    end

end

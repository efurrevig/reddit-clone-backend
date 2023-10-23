class UsersController < ApplicationController
    before_action :authenticate_user!

    def update_avatar
        if current_user.update(user_params)
            render json: {
                status: {
                    code: 200
                },
                data: {
                    avatar_key: current_user.avatar_key
                }
            }
        else
            render json: {
                status: {
                    code: 422
                },
                errors: 'Failed update avatar'
            }, status: 422
        end
    end

    def get_avatar_presigned_url
        url_object = presigned_url(params[:fileType])
        UpdateAvatarJob.perform_at(10.seconds.from_now, current_user.id, url_object[:key], current_user.avatar_key)
        render json: {
            status: {
                code: 200
            },
            data: url_object
        }, status: 200
    rescue Aws::Errors::ServiceError => e
        render json: {
            status: {
                code: 422
            },
            errors: e.message
        }
    end

    private

    def user_params
        params.require(:user).permit(:avatar_key)
    end
end

class CommunitiesController < ApplicationController
    before_action :authenticate_user!, only: [:create, :destroy]
    # status: public, private, hidden
    def index
        @communities = Community.all
        render json: {
            status: {
                code: 200
            },
            data: @communities
        }
    end

    def show
    end

    def create
        @community = Community.create(community_params)

        if @community.save
            render json: {
                status: {
                    code: 200,
                    message: "Community successfully created."
                },
                data: @community
            }
        else
            render json: {
                status: {
                    code: 422,
                    message: @community.errors.messages
                }
            }, status: 422
        end
    end

    def destroy
        @community = Community.find(params[:id])

        @community.destroy
        render json: {
            status: {
                code: 200,
                message: "Community successfully removed."
            }
        }
    end

    private
    def community_params
        params.require(:community).permit(:name)
    end 
end

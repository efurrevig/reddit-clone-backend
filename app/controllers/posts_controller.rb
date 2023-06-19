class PostsController < ApplicationController

    #GET /api/communities/:community_id/posts
    def index
        @community = Community.find(params[:community_id])
        @posts = @community.posts

        if @posts.length > 0
            render json: {
                status: {
                    code: 200
                },
                data: @posts
            }
        else
            head 204
        end
    end

    #GET /api/users/:user_id/posts
    def user_posts
        user = User.find(params[:user_id])
        @posts = user.posts

        if @posts.length > 0
            render json: {
                status: {
                    code: 200
                },
                data: @posts
            }
        else
            head 204
        end

    end

    #GET /api/communities/:community_id/posts/:id
    def show

    end

    #POST /api/communities/:community_id/posts
    def create

    end

    #PATCH/PUT /api/communities/:community_id/posts/:id
    def edit

    end

    #DELETE /api/communities/:community_id/posts/:id
    def destroy

    end

    private

    def post_params
        params.require(:post).permit(:title, :body, :post_type, :media_url)
    end
end

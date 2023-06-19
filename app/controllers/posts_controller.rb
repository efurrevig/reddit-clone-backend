class PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :edit, :destroy]
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

    rescue ActiveRecord::RecordNotFound
        head 404
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
    rescue ActiveRecord::RecordNotFound
        head 404

    end

    #GET /api/communities/:community_id/posts/:id
    def show
        post = Post.find(params[:id])
        render json: {
            status: {
                code: 200
            },
            data: post
        }
    rescue ActiveRecord::RecordNotFound
        head 404
 

    end

    #POST /api/communities/:community_id/posts
    def create
        community = Community.find(params[:community_id])
        post = community.posts.build(post_params)
        post.save!
        render json: {
            status: {
                code: 201
            },
            data: post
        }, status: 201
        rescue ActiveRecord::RecordInvalid
            render json: {
                status: {
                    code: 422,
                    message: post.errors.full_messages
                }
            }, status: 422
        rescue ActiveRecord::NotNullViolation
            render json: {
                status: {
                    code: 422,
                    message: "Please fill out all required fields"
                }
            }, status: 422


    end

    #PATCH/PUT /api/communities/:community_id/posts/:id
    def edit

    end

    #DELETE /api/communities/:community_id/posts/:id
    def destroy

    end

    private

    def post_params
        params.require(:post).permit(:title, :body, :post_type, :media_url, :user_id)
    end
end

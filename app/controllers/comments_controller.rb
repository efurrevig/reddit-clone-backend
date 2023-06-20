class CommentsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :verify_comment_owner, only: [:update, :destroy]
    
    # def index
    #     post = Post.find(params[:post_id])
    #     comments = post.comments.includes(:user, :child_comments)
    #     render json: {
    #         status: {
    #             code: 200
    #         },
    #         data: comments
    #     }

    # rescue ActiveRecord::RecordNotFound
    #     head 404
    # end

    def create
        post = Post.find(params[:post_id])
        comment = post.comments.build(comment_params)
        comment.user_id = current_user.id
        if comment.save
            render json: {
                status: {
                    code: 200
                },
                data: comment
            }
        else
            render json: {
                status: {
                    code: 422
                },
                errors: comment.errors.full_messages
            }, status: 422
        end
    end

    def update

    end

    def destroy

    end

    private
    def comment_params
        params.require(:comment).permit(:body, :user_id, :post_id, :parent_comment_id)
    end

    def verify_comment_owner
        comment = Comment.find(params[:id])
        head :forbidden unless comment.user_id == current_user&.id
    rescue ActiveRecord::RecordNotFound
        head 404
    end
end

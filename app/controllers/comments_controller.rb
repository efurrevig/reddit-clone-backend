class CommentsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :verify_comment_owner, only: [:update, :destroy]
    before_action :get_comment, only: [:update, :destroy]
    
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

    #PUT /api/posts/:post_id/comments
    def create
        commentable = params[:comment][:commentable_type].constantize.find(params[:comment][:commentable_id])
        comment = commentable.comments.build(comment_params)
       #comment.user_id = current_user.id
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
    rescue ActiveRecord::RecordNotFound
        head 404
    end

    #PATCH /api/comments/:id
    def update
        if @comment.update(edit_comment_params)
            render json: {
                status: {
                    code: 200
                },
                data: @comment
            }
        else
            render json: {
                status: {
                    code: 422
                },
                errors: @comment.errors.full_messages
            }, status: 422
        end
    end

    #DELETE /api/comments/:id
    def destroy
        @comment.update!(is_deleted?: true)
        head :no_content
    end

    private
    def comment_params
        params.require(:comment).permit(:body, :user_id, :commentable_type, :commentable_id)
    end

    def edit_comment_params
        params.require(:comment).permit(:body)
    end

    def verify_comment_owner
        comment = Comment.find(params[:id])
        head :forbidden unless comment.user_id == current_user.id
    rescue ActiveRecord::RecordNotFound
        head 404
    end

    def get_comment
        @comment = Comment.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        head 404
    end
end
class CommentsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :verify_comment_owner, only: [:update, :destroy]
    
    def index
        
    end

    def create

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

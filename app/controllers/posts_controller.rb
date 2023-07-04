class PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy, :upvote, :downvote]
    before_action :verify_owner, only: [:update, :destroy]

    #GET /api/communities/:community_id/posts
    def index
        @community = Community.includes(posts: :user).find(params[:community_id])
        @posts = pack_posts(@community.posts)

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
        post = Post.includes(comments: [:user, :comments]).find(params[:id])
        post_comments = pack_comments(post.comments)
        render json: {
            status: {
                code: 200
            },
            data: { post: post, comments: post_comments }
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
    def update
        post = Post.find(params[:id])
        post.update!(edit_post_params)
        render json: {
            status: {
                code: 200
            },
            data: post
        }, status: 200

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

    rescue ActiveRecord::RecordNotFound
        head 404

    end

    #DELETE /api/communities/:community_id/posts/:id
    def destroy
        post = Post.find(params[:id])
        post.update!(is_deleted?: true)

    rescue ActiveRecord::RecordNotFound
        head 404

    end


    def vote_post(direction)
        vote = Vote.find_or_initialize_by(votable_type: "Post", votable_id: params[:id], user_id: current_user.id)
        vote.value = (vote.value == direction ? 0 : direction)
        if vote.save
            head 200
        else
            render json: {
                status: {
                    code: 422,
                    message: vote.errors.full_messages
                }
            }, status: 422
        end
    end

    def upvote
        vote_post(1)
    end

    def downvote
        vote_post(-1)
    end



    private

    def post_params
        params.require(:post).permit(:title, :body, :post_type, :media_url, :user_id)
    end

    def edit_post_params
        params.require(:post).permit(:title, :body, :post_type, :media_url)
    end

    def verify_owner
        post = Post.find(params[:id])
        head :forbidden unless post.user_id == current_user.id
    rescue ActiveRecord::RecordNotFound
        head 404
    end

    # def get_post
    #     @post = Post.find(params[:id])
    # rescue ActiveRecord::RecordNotFound
    #     head 404
    # end


    #generating comment tree, probably not the best way to do it
    #but it works for now, will refactor later
    def pack_comments(comments)
        comments.map do |comment|
          {
            id: comment.id,
            body: comment.body,
            username: comment.user.username,
            commentable_id: comment.commentable_id,
            commentable_type: comment.commentable_type,
            level: 0,
            comments: pack_comments(comment.comments)
          }
        end
    end

    def pack_posts(posts)
        posts.map do |post|
            {
                id: post.id,
                title: post.title,
                body: post.body,
                post_type: post.post_type,
                media_url: post.media_url,
                username: post.user.username,
                community_id: post.community_id
            }
        end
    end
end

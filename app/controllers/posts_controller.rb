class PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy, :upvote, :downvote]
    before_action :verify_owner, only: [:update, :destroy]

    #GET /api/communities/:community_id/posts
    def index
        if current_user != nil
            posts = Post.fetch_posts_with_user(params[:sorted_by], params[:community_id], current_user.id)
        else
            posts = Post.fetch_posts_without_user(params[:sorted_by], params[:community_id])
        end


        render json: {
            status: {
                code: 200
            },
            data: posts
        }


    rescue ActiveRecord::RecordNotFound
        head 404
    end

    def home_posts
        get_home_posts(params[:sorted_by])
    end

    def get_home_posts(sorted_by, page = nil)
        if current_user != nil
            posts = Post.fetch_home_posts_with_user(sorted_by, current_user.id, page)
        else
            posts = Post.fetch_home_posts_without_user(sorted_by, page)
        end

        render json: {
            status: {
                code: 200
            },
            data: posts
        }
 
    end

    def community_posts
        fetch_posts(params[:sorted_by], params[:community_id])
    end

    def fetch_posts(sorted_by, community_id)
        if current_user != nil
            posts = Post.fetch_posts_with_user(sorted_by, community_id, current_user.id)
        else
            posts = Post.fetch_posts_without_user(sorted_by, community_id)
        end

        render json: {
            status: {
                code: 200
            },
            data: posts
        }



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

    #GET /api/communities/:community_id/posts/:id ???
    #get '/posts/:id'
    def show
        if current_user != nil
            post = Post.fetch_post_with_user(params[:id], current_user.id)
            comments = post.get_post_comments_with_user(params[:sorted_by], current_user.id)
        else
            post = Post.select('posts.*, users.username as author').joins(:user).where(id: params[:id]).first
            comments = post.get_post_comments_without_user(params[:sorted_by])
        end
        comments.each do |comment|
            puts comment.id
        end
        render json: {
            status: {
                code: 200
            },
            data: { post: post, comments: comments.to_json }
        }
    rescue ActiveRecord::RecordNotFound
        head 404
 

    end

    #POST /api/communities/:community_id/posts
    def create
        Rails.logger.info(JSON.parse(request.body.read))
        community = Community.find(params[:community_id])
        post = community.posts.build(post_params)
        post.user_id = current_user.id
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
        vote.prev_value = vote.value
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
        params.require(:post).permit(:title, :body, :post_type, :url)
    end

    def edit_post_params
        params.require(:post).permit(:title, :body, :post_type, :url)
    end

    def verify_owner
        post = Post.find(params[:id])
        head :forbidden unless post.user_id == current_user.id
    rescue ActiveRecord::RecordNotFound
        head 404
    end


end

class PostsController < ApplicationController
    before_action :authenticate_user!, only: [:create, :update, :destroy, :upvote, :downvote, :home_posts_hot]
    before_action :verify_owner, only: [:update, :destroy]

    #GET /api/communities/:community_id/posts
    def index
        if current_user != nil
            posts = Post.fetch_posts_with_user(params[:sorted_by], params[:community_id], current_user.id)
        else
            posts = Post.fetch_posts_without_user(params[:sorted_by], params[:community_id])
        end

        if posts.length > 0
            render json: {
                status: {
                    code: 200
                },
                data: posts
            }
        else
            head 204
        end

    rescue ActiveRecord::RecordNotFound
        head 404
    end

    def home_posts_hot
        get_home_posts('hot', current_user.id)
    end

    def home_posts_new

    end

    def home_posts_top
        
    end

    def get_home_posts(sorted_by, user_id, page = nil)
        posts = Post.fetch_home_posts(sorted_by, user_id, page)
        if posts.length > 0
            render json: {
                status: {
                    code: 200
                },
                data: posts
            }
        else
            head 204
        end
    end

    def community_posts_hot
        fetch_posts('hot', params[:community_id])
    end

    def community_posts_new
        fetch_posts('new', params[:community_id])
    end

    def community_posts_top
        fetch_posts('top', params[:community_id])
    end

    def fetch_posts(sorted_by, community_id)
        if current_user != nil
            posts = Post.fetch_posts_with_user(sorted_by, community_id, current_user.id)
        else
            posts = Post.fetch_posts_without_user(sorted_by, community_id)
        end

        if posts.length > 0
            render json: {
                status: {
                    code: 200
                },
                data: posts
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
        post = Post.includes(comments: [:user, :comments, :votes])
            .find(params[:id])
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
            vote_count: comment.vote_count,
            voted: current_user == nil ? 0 : comment.votes.find_by(user_id: current_user.id).value || 0,
            comments: pack_comments(comment.comments)
          }
        end
    end

    def pack_posts(posts)
        posts.map do |post|
            vote = current_user == nil ? nil : post.votes.find_by(user_id: current_user.id)
            {
                id: post.id,
                title: post.title,
                body: post.body,
                post_type: post.post_type,
                media_url: post.media_url,
                username: post.user.username,
                community_id: post.community_id,
                vote_count: post.vote_count,
                voted: vote == nil ? 0 : vote.value,
                is_deleted?: post.is_deleted?,
            }
        end
    end
end

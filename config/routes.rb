require 'sidekiq/api'
Rails.application.routes.draw do

  get 'current_user', to: 'current_user#index'

  devise_for :users, path: '', path_names: {
    sign_in: 'api/login',
    sign_out: 'api/logout',
    registration: 'api/signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  scope '/api' do
    #user routes
    get '/users/:user_id/posts', to: 'posts#user_posts'
      #user avatar presigned
    get '/users/url/:fileType', to: 'users#get_avatar_presigned_url'
    resources :communities do
      resources :subscribers
      resources :posts, except: [:show]
    end

    #DELETE THIS
    get '/posts/hello', to: 'posts#hello'

    get '/communities/search/:q', to: 'communities#search'
    #community posts
    get '/communities/:community_id/posts/:sorted_by/:page', to: 'posts#community_posts'
    #user community subscription
    get '/communities/:community_id/subscription', to: 'communities#user_community_subscription'
    #user subscribed communities
    get '/subscribedcommunities', to: 'communities#user_subscribed_communities'



    get '/posts/:id', to: 'posts#show'

    post '/posts/:id/upvote', to: 'posts#upvote'
    post '/posts/:id/downvote', to: 'posts#downvote'

    post '/comments/:id/upvote', to: 'comments#upvote'
    post '/comments/:id/downvote', to: 'comments#downvote'

    resources :comments, only: [:update, :destroy]
    post '/posts/:post_id/comments', to: 'comments#create'
    post '/comments/:comment_id/comments', to: 'comments#create'



    #home post routes (all subscribed community posts if logged in or all posts if not logged in)
    get '/posts/:feed/:sorted_by/:page', to: 'posts#feed_posts'


  end


end

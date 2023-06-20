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
    get '/users/:user_id/posts', to: 'posts#user_posts'
    resources :communities do
      resources :subscribers
      resources :posts
    end

    get '/posts/:post_id/comments', to: 'comments#index'
  end


end

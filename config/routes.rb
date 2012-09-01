GetCredible::Application.routes.draw do

  # resque
  mount Resque::Server.new, at: "/resque"

  # devise
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    invitations: 'users/invitations',
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "users/omniauth_callbacks/disconnect/:provider",
       to: "users/omniauth_callbacks#disconnect",
       as: "disconnect_provider"
    get '/i' => 'users/invitations#edit', as: :accept_invitation
  end


  # root
  root to: 'home#index'

  # fixed
  get '/privacy' => 'home#privacy'
  get '/terms' => 'home#terms'
  get '/tour' => 'home#tour'
  get '/press' => 'home#press'
  get '/team' => 'home#team'
  get '/about' => 'home#about'
  get '/invite' => 'invite#index'
  get '/invite/state' => 'invite#state'
  get '/sitemap.:format' => 'home#sitemap', as: :sitemap
  post '/tags/search'
  match '/search' => 'users#index', as: 'search'

  # resources
  resources :activities, only: [:show]
  resources :invitation_messages, only: [:create]

  # user namespace
  match '/:user_id' => 'users#show', as: 'user'
  match '/:user_id/followers' => 'users#followers', as: 'user_followers'
  match '/:user_id/following' => 'users#following', as: 'user_following'
  scope "/:user_id", as: :user do
    resources :links, only: [:create, :index, :destroy]
    resources :endorsements
    resources :friendships
    resources :user_tags, only: [:index, :create, :destroy], path: :tags do
      member do
        post :vote
        post :unvote
      end
    end
  end
end

GetCredible::Application.routes.draw do

  root :to => 'home#index'

  mount Resque::Server.new, :at => "/resque"

  get '/invite' => 'invite#index'
  get '/invite/state' => 'invite#state'
  get '/sitemap.:format' => 'home#sitemap', :as => :sitemap
  post "tags/search"

  # devise
  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
    :invitations => 'users/invitations',
    :omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "users/omniauth_callbacks/disconnect/:provider", to: "users/omniauth_callbacks#disconnect",
           as: "disconnect_provider"#, constraints: {provider: [:twitter, :linkedin]}
    get '/i' => 'users/invitations#edit', as: :accept_invitation
    # TODO #get 'users/registrations/change_password', to: 'users/registrations#change_password'
  end

  # resources
  resources :users, :only => [:index, :show] do
    resources :endorsements
    resources :friendships
    resources :links, :only => [:create, :index, :destroy]
    resources :user_tags, :only => [:index, :create, :destroy], :path => :tags do
      member do
        post :vote
        post :unvote
      end
    end
  end
  resources :activities, :only => [:show]
  resources :invitation_messages, :only => [:create]

  # static pages
  get '/privacy' => 'home#privacy'
  get '/terms' => 'home#terms'
  get '/tour' => 'home#tour'
  get '/press' => 'home#press'
  get '/team' => 'home#team'
  get '/about' => 'home#about'

  # user namespace
  match '/:id' => 'users#show', :as => 'me_user'
  match '/:id/followers' => 'users#followers', :as => 'user_followers'
  match '/:id/following' => 'users#following', :as => 'user_following'
  match '/:id/links' => 'links#index', :as => 'me_user_links'
end

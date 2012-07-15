GetCredible::Application.routes.draw do
  mount Resque::Server.new, :at => "/resque"
  post "tags/search"
  get '/invite' => 'invite#index'
  get '/sitemap.:format' => 'home#sitemap', :as => :sitemap
  get '/i' => 'users/invitations#edit', as: :accept_invitation

  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
    :invitations => 'users/invitations',
    :omniauth_callbacks => "users/omniauth_callbacks"
  }
  devise_scope :user do
    delete "users/omniauth_callbacks/disconnect/:provider", to: "users/omniauth_callbacks#disconnect",
           as: "disconnect_provider"#, constraints: {provider: [:twitter, :linkedin]}
  end

  resources :users, :only => [:index, :show] do
    resources :endorsements
    resources :user_tags, :only => [:index, :create, :destroy], :path => :tags do
      member do
        post :vote
        post :unvote
      end
    end
  end

  resources :activities, :only => [:show]
  resources :invitation_messages, :only => [:create]

  root :to => 'home#index'

  # static pages
  get '/privacy' => 'home#privacy'
  get '/terms' => 'home#terms'
  get '/tour' => 'home#tour'
  get '/press' => 'home#press'
  get '/team' => 'home#team'
  get '/about' => 'home#about'

  match '/:id' => 'users#show', :as => 'me_user'
  match '/:id/followers' => 'users#followers', :as => 'user_followers'
  match '/:id/following' => 'users#following', :as => 'user_following'
end

GetCredible::Application.routes.draw do

  post "tags/search"

  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
    :invitations => 'users/invitations'
  } #do
    #get "users/invitations", :to => "users/invitations#index", :as => "user_invitations"
  #end

  resources :users, :only => [:index, :show] do
    resources :user_tags, :only => [:index, :create, :destroy], :path => :tags do
      member do
        post :vote
        post :unvote
      end
    end
  end

  resources :activities, :only => [:show]

  root :to => 'home#index'

  get '/privacy' => 'home#privacy'
  get '/terms' => 'home#terms'
  get '/tour' => 'home#tour'

  namespace :twitter do
    resource :session, :only => [:new, :show, :destroy]
    resources :messages, :only => [:create]
    resources :contacts, :only => [:index] do
      collection do
        get :import
      end
    end
  end

  match '/:id' => 'users#show', :as => 'me_user'
end

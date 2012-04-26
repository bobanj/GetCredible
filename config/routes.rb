GetCredible::Application.routes.draw do

  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "users/sessions",
    :registrations => "users/registrations"
  }

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

  match '/:id' => 'users#show', :as => 'me_user'
end

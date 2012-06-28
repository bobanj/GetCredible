GetCredible::Application.routes.draw do

  post "tags/search"
  get '/people' => 'people#index'
  get '/people/invite' => 'people#invite'
  get '/people/tagged' => 'people#tagged'
  get '/people/tagged_you' => 'people#tagged_you'

  devise_for :users, :controllers => {
    :sessions => "users/sessions",
    :registrations => "users/registrations",
    :invitations => 'users/invitations'
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

  namespace :twitter do
    resource :session, :only => [:new, :show, :destroy]
    resources :messages, :only => [:create]
    resources :contacts, :only => [:index]
  end

  root :to => 'home#index'

  # static pages
  get '/privacy' => 'home#privacy'
  get '/terms' => 'home#terms'
  get '/tour' => 'home#tour'
  get '/press' => 'home#press'

  match '/:id' => 'users#show', :as => 'me_user'
end

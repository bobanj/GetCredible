GetCredible::Application.routes.draw do
  get "home/index"
  get "home/activity"
  get "home/search"
  get "home/show_profile"
  get "home/edit_profile"
  get "home/invite_email"
  get "home/invite_twitter"

  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "users/sessions",
    :invitations => "users/invitations"
  }

  resources :users, :only => [:index, :show] do
    collection do
      get :login_as
    end
    member do
      get :incoming
      get :outgoing
      get :all
    end
    resources :user_tags, :only => [:index, :create, :destroy], :path => :tags do
      member do
        post :vote
        post :unvote
      end
    end
  end

  root :to => 'home#index'

  match '/:id' => 'users#show', :as => 'me_user'
end

Cenit::Application.routes.draw do
  mount RailsAdmin::Engine => '/data', as: 'rails_admin'
  use_doorkeeper
  devise_for :users
  # devise_for :users, :controllers => {:registrations => "registrations"}
  root to: "home#index"
  
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
    # put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'devise/registrations#update_card'
  end

  namespace :api do
    namespace :v1 do
      resources :status
      resources :users
      get '/me' => "credentials#me"
      get '/fast' => 'fast#index'
    end
  end
  
  get '/about_us' => 'about_us#index', :as => 'about_us'
 get '/hub' => 'hub#index', :as => 'hub'
  get '/features' => 'features#index', :as => 'features'
  get '/services' => 'services#index', :as => 'services'
  get '/status/:id' => 'status#show', :as => 'status'

end

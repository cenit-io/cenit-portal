Cenit::Application.routes.draw do
  use_doorkeeper
  #devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}
  root to: "home#index"
  
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
  end

  namespace :api do
    namespace :v1 do
      resources :profiles
      resources :users
      get '/me' => "credentials#me"
      get '/fast' => 'fast#index'
    end
  end
  
  get '/about_us' => 'about_us#index', :as => 'about_us'
  get '/contact_us' => 'contact_us#index', :as => 'contact_us'
  get '/features' => 'features#index', :as => 'features'
  get '/services' => 'services#index', :as => 'services'

end

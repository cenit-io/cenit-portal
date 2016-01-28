Cenit::Application.routes.draw do
  get 'directory/autocomplete_item_name'
  resources :directory

  resources :profiles

  mount RailsAdmin::Engine => '/data', as: 'rails_admin'
  use_doorkeeper

  root to: 'home#index'
  
  devise_for :users, controllers: { confirmations: 'confirmations' }

  devise_scope :user do
    # get 'users/sign_out', to: 'devise/sessions#destroy'
    put 'update_card', to: 'devise/registrations#update_card'
  end

  namespace :api do
    namespace :v1 do
      resources :status
      resources :users
      # resources :profiles, only: [:index, :create]
      resources :app_logs, only: [:index, :create]
      get '/me', to: 'credentials#me'
      # get '/fast' => 'fast#index'
    end
  end
  
  resources :blog, only: [:index, :new] do
    collection do
      get :cenit_api_collections_for_google_services
      get :first_anniversary
      get :asana_integration
      get :mailchimp_integration
      get :using_twitter_integration_on_odoo
      get :installing_twitter_integration_on_odoo
      get :cenit_integration_client_on_odoo
      get :shipwire_integration
    end
  end

  resources :partnership, only: :index
  resources :cenithub, only: :index
  
  get '/about_us', to: 'about_us#index', as: :about_us
  get '/hub', to: 'hub#index', as: :hub
  get '/terms_of_service', to: 'terms_of_service#index', as: :terms_of_service
  get '/features', to: 'features#index', as: :features
  get '/api_references', to: 'api_references#index', as: :api_references
  get '/services', to: 'services#index', as: :services
  get '/status/:id', to: 'status#show', as: :status
end

Cenit::Application.routes.draw do
  root to: 'blog#index'
  
  resources :blog, only: :index do
    collection do
      get :multi_channel_messaging
      get :gmail_cenit_collection
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
  
  resources :terms_of_service, only: :index
end

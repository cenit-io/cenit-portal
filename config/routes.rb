Cenit::Application.routes.draw do
  #devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}
  root to: "home#index"
  
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
  end
  
  get '/about_us' => 'about_us#index', :as => 'about_us'
  get '/contact_us' => 'contact_us#index', :as => 'contact_us'
  get '/features' => 'features#index', :as => 'features'
  get '/services' => 'services#index', :as => 'services'

end

Cenit::Application.routes.draw do
  #devise_for :users
  devise_for :users, :controllers => {:registrations => "registrations"}
  root to: "home#index"
  
  devise_scope :user do
    get 'users/sign_out' => "devise/sessions#destroy"
  end

end

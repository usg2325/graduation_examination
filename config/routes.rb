Rails.application.routes.draw do
  get 'user_sessions/new'
  get 'users/new'
  root 'top_pages#top'

  resources :users
  get 'sign_up', to: 'users#new'
  get 'app_top', to: 'top_pages#app_top'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  get 'guide_spotify_login', to: 'user_sessions#guide_spotify_login'

  get '/spotify_login', to: 'spotify#login'
  get '/spotify_callback', to: 'spotify#callback'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

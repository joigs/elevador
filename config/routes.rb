Rails.application.routes.draw do
  resources :ruletypes
  resources :rulesets
  resources :groups

  root 'home#index', as: 'home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :authentication, path: '', as: '' do
    resources :users, only: [:new, :create], path: '/register', path_names: { new: '/' }
    resources :sessions, only: [:new, :create, :destroy], path: '/login', path_names: { new: '/' }
  end

  resources :users, only: :show, path: '/user', param: :username
  resources :inspections, path: '/inspections'
  resources :groups, only: [:new, :create, :index, :show, :destroy], path: '/groups'
  resources :rules, path: '/rules'
  resources :ruletypes, only: [:new, :create, :index, :destroy, :show], path: '/ruletypes'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

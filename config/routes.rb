Rails.application.routes.draw do


  resources :details
  resources :ladder_details
  resources :reports
  resources :items

  root 'home#index', as: 'home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :authentication, path: '', as: '' do
    resources :users, path: '/register'
    resources :sessions, only: [:new, :create, :destroy], path: '/login', path_names: { new: '/' }
  end

  resources :users, only: :show, path: '/user', param: :username, as: 'perfil'
  resources :inspections, path: '/inspections' do
    member do
      get :download_document
      patch :close_inspection
    end
  end
  resources :groups, only: [:new, :create, :index, :show, :destroy], path: '/groups'
  resources :rules  , path: '/rules' do
    collection do
      get :new_with_new_code
      get :new_with_same_code
      post :create_with_new_code
      post :create_with_same_code
      get :new_import
      post :import
    end
  end

  resources :ruletypes, only: [:new, :create, :index, :destroy, :show], path: '/ruletypes' do
    collection do
      get :new_import
      post :import
    end
  end
  resources :ladders, path: '/ladders' do
    collection do
      get :new_import
      post :import
    end
  end
  resources :items, path: '/items'
  resources :principals, path: '/principals' do
    get :items, on: :member
    get :places, on: :member
  end
  resources :revisions, path: '/revisions'
  resources :ladder_revisions, path: '/ladder_revisions'
  get 'warnings', to: 'static_pages#warnings'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

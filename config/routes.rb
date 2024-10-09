Rails.application.routes.draw do

  get "/service-worker.js" => "service_worker#service_worker"
  get "/manifest.json" => "service_worker#manifest"

  resources :details
  resources :ladder_details
  resources :reports
  resources :items do
    member do
      get 'edit_identificador'
      patch 'update_identificador'
      get 'edit_empresa'
      patch 'update_empresa'
    end
  end
  root 'home#index', as: 'home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :authentication, path: '', as: '' do
    resources :users, path: '/users'
    resources :sessions, only: [:new, :create, :destroy], path: '/login', path_names: { new: '/' }
  end

  resources :users, only: :show, path: '/user', param: :username, as: 'perfil' do
    member do
      patch :toggle_tabla
    end
  end


  resources :inspections, path: '/inspections' do
    member do
      get :download_document
      patch :close_inspection
      patch :update_ending
      get :download_json
      patch :update_inf_date
      get :new_with_last
      #get :download_images

    end

  end
  resources :groups, only: [:new, :create, :index, :show, :destroy], path: '/groups' do
    collection do
      get 'libre', to: 'groups#libre', as: 'libre'
    end
  end
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
  #do
  #  member do
  #    get 'edit_libre', to: 'revisions#edit_libre'
  #    get 'new_rule', to: 'revisions#new_rule'
  #    post 'create_rule', to: 'revisions#create_rule'
  #  end
  #end


  resources :ladder_revisions, path: '/ladder_revisions'
  get 'warnings', to: 'static_pages#warnings'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

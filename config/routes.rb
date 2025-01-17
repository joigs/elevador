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
      get 'edit_group'
      patch 'update_group'
    end
  end
  root 'home#index', as: 'home'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  namespace :authentication, path: '', as: '' do
    resources :users, path: '/users' do
      collection do
        get :new_client
        post :create_client
      end
      member do
        get :edit_client
        patch :update_client
        get :manage_permisos
        patch :update_permisos
      end
    end
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
      patch :force_close_inspection
      get :edit_informe
      patch :update_informe
      get :download_informe
    end

    #get :download_images
    collection do
      get :edit_massive_load
      patch :update_massive_load
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
    get :no_conformidad
    get :estado_activos
    get :defectos_activos
  end
  resources :revisions, path: '/revisions' do
    member do
      #get 'edit_libre', to: 'revisions#edit_libre'
      get 'new_rule', to: 'revisions#new_rule'
      post 'create_rule', to: 'revisions#create_rule'
    end
  end


  resources :ladder_revisions, path: '/ladder_revisions'

  resources :revision_photos, only: [:destroy] do
    member do
      patch :rotate
    end
  end

  resources :facturacions, path: 'cotizaciones' do

    member do
      get :download_solicitud_file
      get :download_cotizacion_doc_file
      get :download_cotizacion_pdf_file
      get :download_orden_compra_file
      get :download_facturacion_file
      get :download_all_files
      patch :upload_cotizacion
      patch :marcar_entregado
      patch :upload_orden_compra
      patch :upload_factura
    end

    resources :observacions, only: %i[index create update destroy]
  end

  resources :permisos


  get 'warnings', to: 'static_pages#warnings'
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

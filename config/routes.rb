Rails.application.routes.draw do
  resources :users
  root to: "homes#top"
  get "products/new"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  post 'products', to: 'products#create'  # 登録
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get 'products', to: 'products#index'
  get 'products/:id', to: 'products#show', as: 'product'
  get 'products/:id/edit', to: 'products#edit', as: 'edit_product'
  patch 'products/:id', to: 'products#update'
  delete 'products/:id', to: 'products#destroy', as: 'destroy_product'
  # Defines the root path route ("/")
  # root "posts#index"
end

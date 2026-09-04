Rails.application.routes.draw do
 devise_for :users
 resources :mypage, only: [:show]
 resources :products
 resources :orders, only: [:index, :new, :create] do
   collection do
     post :confirm
   end
   member do
     get :complete
   end
 end
 root to: "homes#top"
 get "up" => "rails/health#show", as: :rails_health_check
end
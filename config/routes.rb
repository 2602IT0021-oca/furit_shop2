Rails.application.routes.draw do
 devise_for :users
 resources :mypage, only: [:show]
 resources :products
 root to: "homes#top"
 # Reveal health status on /up
 get "up" => "rails/health#show", as: :rails_health_check
end
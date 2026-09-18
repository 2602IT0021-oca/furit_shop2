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

  resources :carts, only: [:show, :index] do
    collection do
      post :add_product
    end

    member do
      delete :remove_item
      post :update_quantity
    end
  end

  # ユーザーのカート内の商品操作
  resources :cart_items, only: [:create, :update, :destroy]

  root to: "homes#top"

  get "up" => "rails/health#show", as: :rails_health_check

end
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :users
  post '/auth/login', to: 'authentication#login'
  get '/categories', to: 'categories#index'
  get '/options', to: 'options#index'
  get '/product/:id', to: 'categories#get_product'

  resources :carts, only: [:show] do
    member do
      post 'add_item'
      delete 'remove_item'
      patch 'update_quantity'
    end
  end

  resources :wish_lists, only: [:show] do
    member do
      post 'add_item'
      delete 'remove_item'
    end
  end

  resources :addresses
  resources :orders
  resources :reviews, only: [:index, :show, :create, :update]
  resources :product_questions
  resources :product_answers
  resources :likes, only: [:create, :update]
end

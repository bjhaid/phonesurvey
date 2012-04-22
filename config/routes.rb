Phonesurvey::Application.routes.draw do
  resources :feedbacks

  resources :surveys

  authenticated :user do
    root :to => 'home#index'
  end

  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]

  resources :products
end

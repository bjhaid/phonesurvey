Phonesurvey::Application.routes.draw do

  authenticated :user do
    root :to => 'products#index'
  end

  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]

  resources :products do
    resources :surveys do
      resources :feedbacks
    end
  end
  mount TropoApp, :at => "/tropo"
end

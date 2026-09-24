Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :customers, only: [:new, :create, :show]
  resources :invoices, only: [:new, :create, :index, :show], param: :uuid
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "sessions#new"
end

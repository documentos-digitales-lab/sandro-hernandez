Rails.application.routes.draw do
  resources :customers, only: [:new, :create, :show, :update]
  resources :invoices, only: [:new]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "customers#new"
end

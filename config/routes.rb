Rails.application.routes.draw do
  get 'auth/sign_in', to: "auth#sign_in_page"
  post 'auth/sign_in', to: "auth#sign_in"
  post 'auth/sign_out', to: "auth#sign_out"
  get 'users/new'
  post 'users', to: "users#create"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "articles#index"

  get "/articles/new", to: "articles#new"
  post "/articles", to: "articles#create"
  get "/articles/:id", to: "articles#show"


end

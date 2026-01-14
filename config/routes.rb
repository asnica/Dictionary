Rails.application.routes.draw do
  get "pages/home"
  get "sessions/new"
  get "users/new"
 
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  get "/signup", to: "users#new"
  post "/users", to: "users#create"

  get  "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"


 
end

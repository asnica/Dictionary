Rails.application.routes.draw do
  get "news/index"
  get "news/article"
  get "news/highlight"
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :users, only: [ :new, :create ]

  get "/signup", to: "users#new"

  resources :sessions, only: [ :new, :create ]


  get  "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"



  resources :word_tags

  resources :words do
    collection do
      get :export_csv
      post :generate_image
    end
    member do
      patch :deactivate
      patch :activate
    end
  end

  resources :quiz_sessions, only: [ :index, :create, :show, :destroy ] do
    member do
      get :play
      get :current_question
      post :retry
      post :previous
    end
    resources :user_answers, only: [ :create ]
  end


  resource :ranking, only: [ :show ], controller: "rankings"
end

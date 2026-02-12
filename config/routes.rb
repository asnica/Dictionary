Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  resources :users, only: [ :new, :create ]

  get "/signup", to: "users#new"

  resources :sessions, only: [ :new, :create ]


  get  "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/word_tags/new", to: "word_tags#new"


  resources :word_tags

  resources :words do
    collection do
      get :export_csv
    end
  end

  resources :quizzes do
    collection do
      get :past_quizzes
    end


    member do
      post :submit_answer
      patch :next_question
      patch :previous_question
      post :grade
      get :result
      post :restart
      post :pause
    end
  end


  resource :ranking, only: [ :show ], controller: "rankings"
end

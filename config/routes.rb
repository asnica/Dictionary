Rails.application.routes.draw do
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
    end
    member do
      patch :deactivate
      patch :activate
    end
  end

  # resources :quizzes do
  #   collection do
  #     get :past_quizzes
  #   end


  #   member do
  #     post :submit_answer
  #     patch :next_question
  #     patch :previous_question
  #     post :grade
  #     get :result
  #     post :restart
  #     post :pause
  #   end
  # end
  #

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

  get "/service-worker.js" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "/manifest.json" => "rails/pwa#manifest", as: :pwa_manifest
end

Rails.application.routes.draw do
  root "static_pages#home"

  resources :users
  get "help", to: "static_pages#help"
  get "about", to: "static_pages#about"
  get "contact", to: "static_pages#contact"
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :account_activations, only: [:edit]

  # # letter_openerで送信したメールを確認するためのページ
  # mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end

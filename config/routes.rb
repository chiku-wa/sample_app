Rails.application.routes.draw do
  root "static_pages#home"

  # ----- 汎用ページのルーティング設定
  get "help", to: "static_pages#help"
  get "about", to: "static_pages#about"
  get "contact", to: "static_pages#contact"
  get "signup", to: "users#new"
  post "signup", to: "users#create"

  # ----- ユーザ関連のルーティング設定
  resources :users

  # ----- ログイン機能のルーティング設定
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :account_activations, only: [:edit]

  # ----- マイクロポスト関連のルーティング設定
  resources :microposts, only: [:create, :destroy]

  # ----- フォロー機能に関するルーティング設定
  # フォローしているユーザ一覧、フォロワー一覧画面のルーティング設定
  resources :users do
    member do
      get(:following, :followers)
    end
  end
  get "following", to: "users#following"

  # フォロー・フォロー解除機能のルーティング設定
  resources :follower_followeds, only: [:create, :destroy]
end

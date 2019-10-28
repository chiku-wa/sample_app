require "rails_helper"

RSpec.describe "SessionsController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  it "有効なログイン情報をリクエストするとセッションとCookiesが生成され、プロフィール画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: {
                       sessions: {
                         name: @user,
                         email: @user.email,
                         password: @user.password,
                       },
                     }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # ログイン情報がCookieに記憶されること
    assert !cookies[:user_id].blank?
    assert !cookies[:remember_token].blank?
  end

  it "無効なログイン情報をリクエストするとセッションが生成されず、ログイン画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: {
                       sessions: {
                         name: "invalid_user",
                         email: "invalid@example.com",
                         password: "foobar",
                       },
                     }

    # ログイン画面に遷移し、セッションが生成されないこと
    assert_template "sessions/new"
    assert session[:user_id].blank?
  end

  it "ログアウトするとセッションが破棄され、TOP画面に遷移すること" do
    # ===========ログイン状態にする
    # ログイン用アクションにリクエストを送る
    post login_path, params: {
                       sessions: {
                         name: @user,
                         email: @user.email,
                         password: @user.password,
                       },
                     }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert session[:user_id] != nil

    # ログイン情報がCookieに記憶されること
    assert !cookies[:user_id].blank?
    assert !cookies[:remember_token].blank?

    # ===========ログアウトする
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"

    # セッションとCookieが破棄されること
    assert session[:user_id].blank?
    assert cookies[:user_id].blank?
    assert cookies[:remember_token].blank?
  end
end

require "rails_helper"

RSpec.describe "SessionsController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  it "有効なログイン情報をリクエストするとセッションが生成されてプロフィール画面がレンダリングされること" do
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
    assert !!session[:user_id]
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

    # プロフィール画面に遷移し、ログイン済みになること
    assert_template "sessions/new"
    assert !session[:user_id]
  end

  it "ログアウトするとセッションが破棄され、TOP画面に遷移すること" do
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"
  end
end

require "rails_helper"

RSpec.describe "SessionsController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  it "remember_meを有効にした状態でログイン情報をリクエストすると、セッションとCookiesが生成され、プロフィール画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_user(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # ログイン情報がCookieに記憶されること
    assert !cookies[:user_id].blank?
    assert !cookies[:remember_token].blank?
  end

  it "remember_meを無効にした状態でログイン情報をリクエストすると、セッションは生成されるが、Cookiesは生成されず、プロフィール画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_user(@user, remember_me: false) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # ログイン情報がCookieに記憶されないこと
    assert cookies[:user_id].blank?
    assert cookies[:remember_token].blank?
  end

  it "remember_meに1以外の文字列をパラメータとしてリクエストすると、remember_meにチェックを入れていない場合と同じ挙動になること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    login_parameters = params_user(@user, remember_me: false)
    # ifの判定でtrueになる値(1以外)をremember_meに設定する
    login_parameters[:remember_me] = "invalid parameter"
    post login_path, params: { sessions: login_parameters }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # ログイン情報がCookieに記憶されないこと
    assert cookies[:user_id].blank?
    assert cookies[:remember_token].blank?
  end

  it "remember_meを有効にした状態でログインし、その後remember_meを無効にしてログインすると、Cookieは破棄され、セッションは保持されたままログインされること" do
    get login_path

    # ログイン用アクションにリクエストを送る(remember_me有効)
    post login_path, params: { sessions: params_user(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # ログイン用アクションにリクエストを送る(remember_me無効)
    post login_path, params: { sessions: params_user(@user, remember_me: false) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !session[:user_id].blank?

    # Cookieが空になること
    assert cookies[:user_id].blank?
    assert cookies[:remember_token].blank?
  end

  it "無効なログイン情報をリクエストするとセッションが生成されず、ログイン画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    user = User.new(
      name: "invalid_user",
      email: "invalid@example.com",
      password: "foobar",
    )
    post login_path, params: { sessions: params_user(user) }

    # ログイン画面に遷移し、セッションが生成されないこと
    assert_template "sessions/new"
    assert session[:user_id].blank?
  end

  it "ログアウトするとセッションが破棄され、TOP画面に遷移すること" do
    # ==============================
    # ===ログイン状態にする
    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_user(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert session[:user_id] != nil

    # ログイン情報がCookieに記憶されること
    assert !cookies[:user_id].blank?
    assert !cookies[:remember_token].blank?

    # ==============================
    # ===ログアウトする
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"

    assert session[:user_id].blank?

    # セッションとCookieが破棄されること
    assert session[:user_id].blank?
    assert cookies[:user_id].blank?
    assert cookies[:remember_token].blank?
  end

  it "ログアウトを2回続けて行った時にエラーにならないこと(ログアウト処理が2重で行われないこと)" do
    # ==============================
    # ===ログイン状態にする
    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_user(@user) }

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert session[:user_id] != nil

    # ==============================
    # ===2回続けてログアウトする
    delete logout_path
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"
  end
end

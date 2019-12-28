require "rails_helper"

RSpec.describe "SessionsController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inacitve = FactoryBot.build(:user_inactive)
    @user_inacitve.save
  end

  it "remember_meを有効にした状態でログイン情報をリクエストすると、セッションとCookiesが生成され、プロフィール画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_login(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン情報がCookieに記憶されること
    remembered_for(remembered: true)
  end

  it "remember_meを無効にした状態でログイン情報をリクエストすると、セッションは生成されるが、Cookiesは生成されず、プロフィール画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_login(@user, remember_me: false) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン情報がCookieに記憶されないこと
    remembered_for(remembered: false)
  end

  it "remember_meに1以外の文字列をパラメータとしてリクエストすると、remember_meにチェックを入れていない場合と同じ挙動になること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    login_parameters = params_login(@user, remember_me: false)
    # ifの判定でtrueになる値(1以外)をremember_meに設定する
    login_parameters[:remember_me] = "invalid parameter"
    post login_path, params: { sessions: login_parameters }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン情報がCookieに記憶されないこと
    remembered_for(remembered: false)
  end

  it "remember_meを有効にした状態でログインし、その後remember_meを無効にしてログインすると、Cookieは破棄され、セッションは保持されたままログインされること" do
    get login_path

    # ログイン用アクションにリクエストを送る(remember_me有効)
    post login_path, params: { sessions: params_login(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン用アクションにリクエストを送る(remember_me無効)
    post login_path, params: { sessions: params_login(@user, remember_me: false) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン情報がCookieに保存されないこと
    remembered_for(remembered: false)
  end

  it "無効なログイン情報をリクエストするとセッションが生成されず、ログイン画面がレンダリングされること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    user = User.new(
      email: "invalid@example.com",
      password: "foobar",
    )
    post login_path, params: { sessions: params_login(user) }

    # ログイン画面に遷移し、セッションが生成されないこと
    assert_template "sessions/new"
    expect(session[:user_id]).to be_blank
  end

  it "有効化していないユーザではログインできず、TOP画面に遷移されること" do
    get login_path

    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_login(@user_inacitve, remember_me: false) }

    follow_redirect!
    assert_template "static_pages/home"
    expect(session[:user_id]).to be_blank
  end

  it "ログアウトするとセッションが破棄され、TOP画面に遷移すること" do
    # ==============================
    # ===ログイン状態にする
    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_login(@user, remember_me: true) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ログイン情報がCookieに記憶されること
    expect(cookies[:user_id]).not_to be_blank
    expect(cookies[:remember_token]).not_to be_blank

    # ==============================
    # ===ログアウトする
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"

    # セッションとCookieが破棄されること
    expect(session[:user_id]).to be_blank
    remembered_for(remembered: false)
  end

  it "ログアウトを2回続けて行った時にエラーにならないこと(ログアウト処理が2重で行われないこと)" do
    # ==============================
    # ===ログイン状態にする
    # ログイン用アクションにリクエストを送る
    post login_path, params: { sessions: params_login(@user) }

    # プロフィール画面に遷移し、ログイン済みになること
    succeed_login

    # ==============================
    # ===2回続けてログアウトする
    delete logout_path
    delete logout_path

    follow_redirect!
    assert_template "static_pages/home"
  end

  # ======================================
  private

  # ログインが成功したことを評価するメソッド
  def succeed_login
    follow_redirect!
    assert_template "users/show"
    expect(session[:user_id]).not_to be_blank
  end

  # ログイン状態が保存されているかを評価するメソッド
  # 引数がtrueなら保存されていること、falseなら保存されていないことを確認する
  def remembered_for(remembered:)
    if remembered
      expect(cookies[:user_id]).not_to be_blank
      expect(cookies[:remember_token]).not_to be_blank
    else
      expect(cookies[:user_id]).to be_blank
      expect(cookies[:remember_token]).to be_blank
    end
  end
end

require "rails_helper"

RSpec.describe "Users signup", type: :request do
  it "有効なユーザ情報をリクエストしてユーザが正常に登録され、セッションが生成されること" do
    get signup_path

    # ユーザ登録用アクションにリクエストを送る
    user = User.new(
      name: "Tom",
      email: "tom@example.com",
      password: "a12345",
      password_confirmation: "a12345",
    )

    expect {
      post users_path, params: { user: params_login(user) }
    }.to change(User, :count).by(1)

    # メールが1件送信されていること
    expect(ActionMailer::Base.deliveries.size).to eq 1

    # TOP画面に遷移し、ログインされないこと
    follow_redirect!
    assert_template "static_pages/home"
    expect(session[:user_id]).to be_blank
  end

  it "無効なユーザ情報をリクエストするとユーザは登録されず、セッションは生成されないこと" do
    get signup_path

    # ユーザ登録用アクションにリクエストを送る
    user = User.new(
      name: "Tom",
      email: "tom.bar",
      password: "123456",
      password_confirmation: "123456",
    )
    expect {
      post users_path, params: { user: params_login(user) }
    }.to change(User, :count).by(0)

    # メールが送信されていないこと
    expect(ActionMailer::Base.deliveries.size).to eq 0

    # サインアップ画面に遷移し、ログインされないこと
    assert_template "users/new"
    expect(session[:user_id]).to be_blank
  end
end

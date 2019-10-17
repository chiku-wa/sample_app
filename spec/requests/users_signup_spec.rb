require "rails_helper"

RSpec.describe "Users signup", type: :request do
  it "有効なユーザ情報をリクエストしてユーザが正常に登録され、セッションが生成されること" do
    get signup_path

    # ユーザ登録用アクションにリクエストを送る
    expect {
      post users_path, params: {
                         user: {
                           name: "Tom",
                           email: "tom@example.com",
                           password: "a12345",
                           password_confirmation: "a12345",
                         },
                       }
    }.to change(User, :count).by(1)

    # プロフィール画面に遷移し、ログイン済みになること
    follow_redirect!
    assert_template "users/show"
    assert !!session[:user_id]
  end

  it "無効なユーザ情報をリクエストするとユーザは登録されず、セッションは生成されないこと" do
    get signup_path

    # ユーザ登録用アクションにリクエストを送る
    expect {
      post users_path, params: {
                         user: {
                           name: "Tom",
                           email: "tom.bar",
                           password: "123456",
                           password_confirmation: "123456",
                         },
                       }
    }.to change(User, :count).by(0)

    # プロフィール画面に遷移し、ログイン済みになること
    assert_template "users/new"
    assert !session[:user_id]
  end
end

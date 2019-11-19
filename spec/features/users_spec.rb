require "rails_helper"

RSpec.feature "Users", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  feature "ログイン済みの場合のみアクセスが許可されたページに未ログイン状態でアクセスする" do
    scenario "ユーザ参照用ページにアクセスするとログイン画面に遷移すること" do
      visit user_path(@user)
      redirected_login_page
    end

    scenario "ユーザ編集用ページにアクセスするとログイン画面に遷移すること" do
      visit edit_user_path(@user)
      redirected_login_page
    end
  end

  # ======================================
  #
  private

  # ログインページに強制的に遷移させられたことを確認するためのメソッド
  def redirected_login_page
    # タイトルが想定どおりであること
    expect(page).to(have_title(full_title("Log in"), exact: true))

    # エラーメッセージが表示されること
    expect(page).to(have_selector(".alert.alert-danger", text: "Please log in."))
  end
end

require "rails_helper"

RSpec.feature "Users", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  feature "未ログインユーザが保護された画面にアクセスされた場合のテスト" do
    scenario "ユーザ一覧画面にアクセスするとログイン画面に遷移し、ログインするとユーザ一覧画面に遷移すること" do
      visit users_path
      expect_login_page

      # ログインするとユーザ一覧画面に遷移すること
      login_operation(@user)
      expect(page).to(have_title(full_title("All users")))
    end

    scenario "ユーザ参照画面にアクセスするとログイン画面に遷移し、ログインするとユーザ参照画面に遷移すること" do
      visit user_path(@user)
      expect_login_page

      # ログインするとユーザ参照画面に遷移すること
      login_operation(@user)
      expect(page).to(have_title(full_title(@user.name)))
    end

    scenario "ユーザ編集画面にアクセスするとログイン画面に遷移し、ログインするとユーザ編集画面に遷移すること" do
      visit edit_user_path(@user)
      expect_login_page

      # ログインするとユーザ編集画面に遷移すること
      login_operation(@user)
      expect(page).to(have_title(full_title("Edit user")))
    end

    scenario "フォローしているユーザ一覧画面に遷移し、ログインするとフォローユーザ一覧画面に遷移すること" do
      visit following_user_path(@user)
      expect_login_page

      # ログインするとフォローユーザ一覧画面に遷移すること
      login_operation(@user)
      expect(page).to(have_title(full_title("Following")))
    end

    scenario "フォロワー一覧画面に遷移し、ログインするとフォロワ一覧画面に遷移すること" do
      visit followers_user_path(@user)
      expect_login_page

      # ログインするとフォローユーザ一覧画面に遷移すること
      login_operation(@user)
      expect(page).to(have_title(full_title("Followers")))
    end
  end

  feature "ログイン後に遷移する画面がログイン不要なページだった場合、想定通り画面遷移するか確認するテスト" do
    scenario "TOP画面に遷移した後にログインした場合は、ユーザプロフィール画面に遷移すること" do
      visit root_path

      login_operation(@user)

      expect(page).to(have_title(full_title(@user.name)))
    end

    scenario "Help画面に遷移した後にログインした場合は、ユーザプロフィール画面に遷移すること" do
      visit help_path

      login_operation(@user)

      expect(page).to(have_title(full_title(@user.name)))
    end

    scenario "Sign up(ユーザ登録)画面に遷移した後にログインした場合は、ユーザプロフィール画面に遷移すること" do
      visit signup_path

      login_operation(@user)

      expect(page).to(have_title(full_title(@user.name)))
    end
  end

  # ======================================
  private

  # ログイン画面に強制的に遷移させられたことを確認するためのメソッド
  def expect_login_page
    # タイトルが想定どおりであること
    expect(page).to(have_title(full_title("Log in"), exact: true))

    # エラーメッセージが表示されること
    expect(page).to have_selector(".alert.alert-danger", text: "Please log in.")
  end
end

require "rails_helper"

RSpec.feature "UsersSignup", type: :feature do
  feature "有効なユーザ情報を入力" do
    scenario "ユーザが1件登録できていること" do
      visit signup_path

      user = User.new(
        name: "Tom",
        email: "tom@example.com",
        password: "a12345",
        password_confirmation: "a12345",
      )
      input_user_form(user)

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(1)

      # TOP画面に遷移し、ログイン成功のメッセージが表示されること
      expect(page).to have_title(full_title)
      expect(page).to have_selector(".alert.alert-info", text: "Please check your email to activate your account.")

      # ログアウト状態のみ表示されるボタンが表示されていること
      display_logout_menu
    end
  end

  feature "無効なユーザ情報を入力" do
    scenario "名前が空、不正なメールアドレス、パスワードと確認用が不一致" do
      visit signup_path

      user = User.new(
        name: "",
        email: "user@invalid",
        password: "foo",
        password_confirmation: "bar",
      )
      input_user_form(user)

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(0)

      expect(page).to have_content("Sign up")

      # Sign up画面のままになること
      expect(page).to have_title(full_title("Sign up"))

      # エラー数が出力されていること
      expect_failed_message([
        "Name can't be blank",
        "Email is invalid",
        "Password confirmation doesn't match Password",
        "Password is too short (minimum is 6 characters)",
      ])
    end

    scenario "すべての項目が空" do
      visit signup_path

      user = User.new(
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
      )
      input_user_form(user)

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(0)

      expect(page).to have_content("Sign up")

      # Sign up画面のままになること
      expect(page).to have_title(full_title("Sign up"))

      # エラー数が出力されていること
      expect_failed_message([
        "Name can't be blank",
        "Email can't be blank",
        "Email is invalid",
        "Password can't be blank",
      ])
    end
  end
end

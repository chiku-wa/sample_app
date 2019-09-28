require "rails_helper"

RSpec.feature "UsersSignup", type: :feature do
  feature "有効なユーザ情報を入力" do
    scenario "ユーザが1件登録できていること" do
      visit signup_path
      user_name = "Tom"
      fill_in("user[name]", with: user_name)
      fill_in("user[email]", with: "tom@example.com")
      fill_in("user[password]", with: "a12345")
      fill_in("user[password_confirmation]", with: "a12345")

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(1)

      expect(page).to have_title(full_title(user_name))
      expect(page).to(have_selector(".alert.alert-success", text: /.+/))
    end
  end

  feature "無効なユーザ情報を入力" do
    scenario "名前が空、不正なメールアドレス、パスワードと確認用が不一致" do
      visit signup_path
      fill_in("user[name]", with: "")
      fill_in("user[email]", with: "user@invalid")
      fill_in("user[password]", with: "foo")
      fill_in("user[password_confirmation]", with: "bar")

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(0)

      expect(page).to have_content("Sign up")

      # エラー数が出力されていること
      expect(page).to(have_content(/The form contains [0-9]* error[s]*/))

      # 入力項目のエラーが出力されていること
      expect(page).to(have_content("Name can't be blank", count: 1))
      expect(page).to(have_content("Email is invalid", count: 1))
      expect(page).to(have_content("Password confirmation doesn't match Password", count: 1))
      expect(page).to(have_content("Password is too short (minimum is 6 characters)", count: 1))
    end

    scenario "すべての項目が空" do
      visit signup_path
      fill_in("user[name]", with: "")
      fill_in("user[email]", with: "")
      fill_in("user[password]", with: "")
      fill_in("user[password_confirmation]", with: "")

      expect {
        click_button("Create my account")
      }.to change(User, :count).by(0)

      expect(page).to have_content("Sign up")

      # エラー数が出力されていること
      expect(page).to(have_content(/The form contains [0-9]* error[s]*/))

      # 入力項目のエラーが出力されていること
      expect(page).to(have_content("Name can't be blank", count: 1))
      expect(page).to(have_content("Email can't be blank", count: 1))
      expect(page).to(have_content("Email is invalid", count: 1))
      expect(page).to(have_content("Password can't be blank", count: 1))
      ˝
    end
  end
end

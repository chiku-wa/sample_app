require "rails_helper"

RSpec.feature "PasswordResets", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inactive = FactoryBot.build(:user_inactive)
    @user_inactive.save
  end

  feature "パスワード再設定リクエスト用画面のテスト" do
    scenario "パスワード再設定リクエスト用画面に遷移できること" do
      operation_password_reset

      expect(page).to(have_title(full_title("Forgot password")))
    end

    scenario "パスワード再設定が成功した場合は成功メッセージが表示されること" do
      operation_password_reset(@user.email)

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Email sent with password reset instructions",
      )
    end

    scenario "存在しないメールアドレスの場合はエラーが表示されること" do
      operation_password_reset("invali.mailaddress")

      # 想定した画面とエラーが表示されていること
      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(".alert.alert-danger", text: "Email address not found")
    end

    scenario "有効化されていないユーザの場合はエラーが表示されること" do
      operation_password_reset(@user_inactive.email)

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(".alert.alert-danger", text: "Account not enabled, please account activated.")
    end

    scenario "パスワード再設定リクエストが成功した後にエラーを発生させても、メッセージが重なって表示されないこと" do
      # パスワード再設定リクエストを成功させる
      operation_password_reset(@user.email)

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Email sent with password reset instructions",
      )

      # 成功メッセージが表示された状態で、エラーが発生するパターンでリクエストを送信する
      fill_in("password_reset[email]", with: "invalid.email")
      click_button("Submit")

      # 存在しないメールアドレスを入力してメッセージが1つだけ表示されていること
      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(".alert.alert-danger", text: "Email address not found")
      expect(page).to have_selector(".alert", count: 1)
    end
  end

  # ======================================
  private

  # パスワードリセット画面に遷移し、引数で渡されたメールアドレスをテキストボックスに入力するメソッド
  # 引数を省略した場合は画面遷移のみでパスワードリセットは行わない
  def operation_password_reset(email = nil)
    visit login_path
    click_link("forgot password")

    unless email.blank?
      fill_in("password_reset[email]", with: email)
      click_button("Submit")
    end
  end
end

require "rails_helper"

RSpec.feature "PasswordResets", type: :feature do

  # ====== 定数定義
  # メール本文から、アプリケーションの相対URLを抜き出すための正規表現
  RELATIVE_URL_REGEX = /(?:"https?\:\/\/.*?)(\/.*?)(?:")/

  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inactive = FactoryBot.build(:user_inactive)
    @user_inactive.save
  end

  feature "パスワード再設定リクエスト用画面のテスト" do
    scenario "パスワード再設定リクエスト用画面に遷移できること" do
      operation_request

      expect(page).to(have_title(full_title("Forgot password")))
    end

    scenario "パスワード再設定が成功した場合は成功メッセージが表示されること" do
      operation_request(@user.email)

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Email sent with password reset instructions",
      )
    end

    scenario "存在しないメールアドレスの場合はエラーが表示されること" do
      operation_request("invali.mailaddress")

      # 想定した画面とエラーが表示されていること
      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(".alert.alert-danger", text: "Email address not found")
    end

    scenario "有効化されていないユーザの場合はエラーが表示されること" do
      operation_request(@user_inactive.email)

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(".alert.alert-danger", text: "Account not enabled, please account activated.")
    end

    scenario "パスワード再設定リクエストが成功した後にエラーを発生させても、メッセージが重なって表示されないこと" do
      # パスワード再設定リクエストを成功させる
      operation_request(@user.email)

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

  feature "パスワード再設定機能のテスト" do
    scenario "正常なパスワードを再設定するとプロフィール画面が表示されること" do
      operation_request(@user.email)

      modify_password = "abcdef"
      operation_reset(modify_password, modify_password)

      # プロフィール画面に遷移し、メッセージが表示されること
      expect(page).to have_title(full_title(@user.name))
      expect(page).to have_selector(".alert.alert-success", text: "Password has been reset.")
      expect(page).to have_selector(".alert", count: 1)
    end

    scenario "2時間経過した場合はエラーメッセージが表示されること" do
      operation_request(@user.email)

      # パスワードリセット日時を2時間前に設定する
      @user.reload
      @user.update_attributes(reset_sent_at: @user.reset_sent_at.ago(2.hours))

      visit_reset_path

      expect(page).to have_title(full_title("Forgot password"))
      expect(page).to have_selector(
        ".alert.alert-danger",
        text: "The URL has expired. Please reset your password again.",
      )
    end

    scenario "パスワード再設定画面のリンクを2回アクセスした場合、2回目はアクセスできないこと" do
      operation_request(@user.email)

      modify_password = "123456"

      # 1回目のパスワードリセットは成功すること
      operation_reset(modify_password, modify_password)
      expect(page).to have_title(full_title(@user.name))

      # 2回目はパスワード再設定画面にアクセスすらできず、パスワード再設定リクエスト画面に遷移すること
      visit_reset_path
      expect(page).to have_title(full_title, exact: true)
    end

    scenario "パスワードが空欄の場合はエラーメッセージが表示されること" do
      operation_request(@user.email)

      operation_reset

      # パスワード再設定画面のまま、Validationのエラーメッセージが表示されること
      expect(page).to have_title(full_title("Reset password"))
      expect(page).to have_selector(".alert.alert-danger", text: "The form contains 1 error")
      expect(page).to have_text("Password can't be blank")
    end

    scenario "パスワードが不正な場合は、Validationのエラーメッセージが表示されること" do
      operation_request(@user.email)

      invalid_password = "12345"
      operation_reset(invalid_password, invalid_password)

      # パスワード再設定画面のまま、Validationのエラーメッセージが表示されること
      expect(page).to have_title(full_title("Reset password"))
      expect(page).to have_selector(".alert.alert-danger", text: "The form contains 1 error")
      expect(page).to have_text("Password is too short (minimum is 6 characters)")
    end
  end

  # ======================================
  private

  # パスワードリセット画面に遷移し、引数で渡されたメールアドレスをテキストボックスに入力するメソッド
  # 引数を省略した場合は画面遷移のみでパスワードリセットは行わない
  def operation_request(email = nil)
    visit login_path
    click_link("forgot password")

    unless email.blank?
      fill_in("password_reset[email]", with: email)
      click_button("Submit")
    end
  end

  # 受信したメール本文のリンクをクリックし、パスワード再設定画面にアクセスするメソッド
  def visit_reset_path
    # 受信したメールのリンクにアクセスし、パスワード再設定画面に遷移する
    mail = ActionMailer::Base.deliveries.last

    # メール本文(HTML)内のリンクの相対パスを抜き出してアクセスする
    reset_path = mail.html_part.body.to_s.scan(RELATIVE_URL_REGEX).join
    visit reset_path
  end

  # パスワード再設定画面からパスワードリセットを行うメソッド
  def operation_reset(password = "", password_confirmation = "")
    visit_reset_path

    # パスワードを再設定する
    fill_in("user[password]", with: password)
    fill_in("user[password_confirmation]", with: password_confirmation)
    click_button("Update password")
  end
end

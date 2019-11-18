require "rails_helper"

RSpec.feature "UsersEdit", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  feature "ユーザ情報を更新する" do
    scenario "ログイン中のユーザの情報がフォームの既定値として設定されること" do
      login_operation

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # パスワード以外の入力フォームに既定値が設定されていること
      expect(page).to have_field(id: "user_name", with: @user.name)
      expect(page).to have_field(id: "user_email", with: @user.email)
    end

    scenario "正常なユーザ情報を入力して更新する" do
      login_operation

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # ユーザ情報を入力する
      modify_name = @user.name.chars.shuffle.join
      modify_email = "modify_" + @user.email
      modify_password = "modified_password"
      user = User.new(
        name: modify_name,
        email: modify_email,
        password: modify_password,
        password_confirmation: modify_password,
      )
      input_user_form(user)

      # ユーザが正常に更新され、プロフィール画面に遷移し、更新された値が表示されること
      expect {
        click_button("Save changes")
        succeed_update(user_name: modify_name)
      }.to change(User, :count).by(0)
    end

    scenario "パスワードを入力していなくとも更新に成功すること" do
      login_operation

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # ユーザ情報を入力する
      modify_name = @user.name.chars.shuffle.join
      modify_email = "modify_" + @user.email
      user = User.new(
        name: modify_name,
        email: modify_email,
      )
      input_user_form(user)

      # ユーザが正常に更新され、TOP画面に遷移すること
      expect {
        click_button("Save changes")
        succeed_update(user_name: modify_name)
      }.to change(User, :count).by(0)
    end

    scenario "名前とメールに異常値を入力するとエラーになること" do
      login_operation

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # ユーザ情報を入力する
      invalid_name = "invalid_name" * 10
      invalid_email = "invalid_email_address"
      user = User.new(
        name: invalid_name,
        email: invalid_email,
        password: "foobar",
        password_confirmation: "foobar",
      )
      input_user_form(user)

      # ユーザ情報が更新されないこと
      expect {
        click_button("Save changes")
      }.to change(User, :count).by(0)

      # エラー数が出力されていること
      expect(page).to(have_content(/The form contains [0-9]* error[s]*/))

      # 入力項目のエラーが出力されていること
      expect(page).to(have_content("Email is invalid", count: 1))
      expect(page).to(have_content("Name is too long", count: 1))
    end
  end

  # ======================================
  #
  private

  # ログイン操作を行うメソッド
  def login_operation
    visit login_path
    user = User.new(
      email: @user.email,
      password: @user.password,
    )
    input_login_form(user, remember_me: true)
    click_button("Log in")
    expect(page).to(have_title(full_title(@user.name)))
  end

  # ユーザ情報の更新が成功したかを検証するためのメソッド
  def succeed_update(user_name:)
    # タイトルが想定どおりであること
    expect(page).to(have_title(full_title(user_name), exact: true))

    # プロフィール画面に表示される名前が想定どおりであること
    expect(page).to(have_content(user_name))

    # 更新成功のメッセージが表示されること
    expect(page).to(have_selector(".alert.alert-success", text: "Profile updated"))
  end
end

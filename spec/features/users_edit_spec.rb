require "rails_helper"

RSpec.feature "UsersEdit", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_second = FactoryBot.build(:user_second)
    @user_second.save
  end

  feature "ユーザ情報を更新する" do
    scenario "ログイン中のユーザの情報がフォームの既定値として設定されること" do
      login_operation(@user)

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # パスワード以外の入力フォームに既定値が設定されていること
      expect(page).to have_field(id: "user_name", with: @user.name)
      expect(page).to have_field(id: "user_email", with: @user.email)
    end

    scenario "正常なユーザ情報を入力して更新する" do
      login_operation(@user)

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # ユーザ情報を入力する
      modify_name = shuffle_name(@user.name)
      modify_email = "modify_" + @user.email
      modify_password = "modified_password"
      user = User.new(
        name: modify_name,
        email: modify_email,
        password: modify_password,
        password_confirmation: modify_password,
      )
      input_user_form(user)

      expect {
        click_button("Save changes")
      }.to change(User, :count).by(0)

      succeed_update(user_name: modify_name)
    end

    scenario "パスワードを入力していなくとも更新に成功すること" do
      login_operation(@user)

      # ユーザ更新画面に遷移する
      click_link("Account")
      click_link("Settings")

      # ユーザ情報を入力する
      modify_name = shuffle_name(@user.name)
      modify_email = "modify_" + @user.email
      user = User.new(
        name: modify_name,
        email: modify_email,
      )
      input_user_form(user)

      expect {
        click_button("Save changes")
      }.to change(User, :count).by(0)

      succeed_update(user_name: modify_name)
    end

    scenario "名前とメールに異常値を入力するとエラーになること" do
      login_operation(@user)

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
      expect_failed_message([
        "Email is invalid",
        "Name is too long",
      ])
    end
  end

  feature "他のユーザからのアクセスが禁止されているページにアクセスしようとしたときのテスト" do
    scenario "他のユーザの編集画面に遷移しようとするとTOP画面に遷移すること" do
      # 自身のアカウントでログインする
      login_operation(@user)

      # 他のユーザの編集画面に遷移しようとする
      visit edit_user_path(@user_second)

      expect(page).to(have_title(full_title))
    end
  end

  # ======================================
  private

  # 引数の名前をシャッフルして返すメソッド
  # 半角スペースで区切られている場合は姓名とみなし、姓と名ごとにシャッフルする
  def shuffle_name(name)
    separator = " "

    name
      .split(separator)
      .map { |c| c.chars.shuffle.join }
      .join(separator)
  end

  # ユーザ情報の更新が成功したかを検証するためのメソッド
  def succeed_update(user_name:)
    # タイトルが想定どおりであること
    expect(page).to(have_title(full_title(user_name), exact: true))

    # プロフィール画面に表示される名前が想定どおりであること
    expect(page).to(have_content(user_name))

    # 更新成功のメッセージが表示されること
    expect(page).to have_selector(".alert.alert-success", text: "Profile updated")
  end
end

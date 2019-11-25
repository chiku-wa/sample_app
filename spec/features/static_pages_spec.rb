require "rails_helper"

RSpec.feature "StaticPages", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  # ---------------
  # Headerに関するテスト
  # ---------------
  feature "Headerにあるリンクが正常に機能すること" do
    scenario "Homeリンク(root_path)が正常に機能すること" do
      visit root_path
      expect(page).to(
        have_link("sample app", href: root_path, count: 1)
      )
      expect(page).to(
        have_link("Home", href: root_path, count: 1)
      )

      click_link "Home"
      expect(page).to(
        have_current_path(root_path)
      )
      expect(page).to(
        have_title(full_title, exact: true)
      )
    end

    scenario "[未ログイン状態]Helpリンクが正常に機能すること" do
      visit root_path
      expect(page).to(
        have_link("Help", href: help_path, count: 1)
      )

      click_link "Help"
      expect(page).to(
        have_current_path((help_path))
      )
      expect(page).to(
        have_title(full_title("Help"), exact: true)
      )
    end

    scenario "[未ログイン状態]Log inリンクが正常に機能すること" do
      visit root_path
      expect(page).to(
        have_link("Log in", href: login_path, count: 1)
      )

      click_link "Log in"
      expect(page).to(
        have_current_path(login_path)
      )
      expect(page).to(have_title(full_title("Log in"), exact: true))
    end

    scenario "[ログイン状態]Usersリンクが正常に機能すること" do
      visit root_path

      # ログインが正常に完了すること
      login_operation(@user)
      display_login_menu

      # ユーザ一覧画面に遷移すること
      click_link("Account")
      click_link("Users")
      expect(page).to(have_title("All users"))
    end
  end

  scenario "[ログイン状態]Profileリンクが正常に機能すること" do
    visit root_path

    # ログインが正常に完了すること
    login_operation(@user)
    display_login_menu

    # ユーザ一覧画面に遷移すること
    click_link("Account")
    click_link("Profile")
    expect(page).to(have_title(@user.name))
  end

  scenario "[ログイン状態]Settingsリンクが正常に機能すること" do
    visit root_path

    # ログインが正常に完了すること
    login_operation(@user)
    display_login_menu

    # ユーザ一覧画面に遷移すること
    click_link("Account")
    click_link("Settings")
    expect(page).to(have_title("Edit user"))
  end

  # ログアウトのテストはfeatures/sessions_spec.rbにて実施

  # ---------------
  # yieldに関するテスト
  # ---------------
  feature "yieldアクションのビューのリンクが正常に機能すること" do
    scenario "Singn up now!リンク" do
      visit root_path
      expect(page).to(
        have_link(href: signup_path, count: 1)
      )

      click_link "Sign up now!"
      expect(page).to(
        have_current_path(signup_path)
      )

      expect(page).to(
        have_title(full_title("Sign up"), exact: true)
      )
    end
  end

  # ---------------
  # Footerに関するテスト
  # ---------------
  feature "Footerにあるリンクが正常に機能すること" do
    scenario "Aboutリンクが正常に機能すること" do
      visit root_path
      expect(page).to(
        have_link("About", href: about_path, count: 1)
      )

      click_link "About"
      expect(page).to(
        have_current_path(about_path)
      )
      expect(page).to(
        have_title(full_title("About"), exact: true)
      )
    end

    scenario "Contactリンクが正常に機能すること" do
      visit root_path
      expect(page).to(
        have_link("Contact", href: contact_path, count: 1)
      )

      click_link "Contact"
      expect(page).to(
        have_current_path(contact_path)
      )
      expect(page).to(
        have_title(full_title("Contact"), exact: true)
      )
    end

    # 「News」は外部リンクなのでテストしない
  end
end

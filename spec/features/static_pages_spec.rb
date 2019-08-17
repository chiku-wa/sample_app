require "rails_helper"

RSpec.feature "StaticPages", type: :feature do
  # ---------------
  # Headerに関するテスト
  # ---------------
  feature "Headerにあるリンクが正常に機能すること" do
    scenario "Homeリンク(root_path)が正常に機能すること" do
      visit root_path
      expect(page).to(have_link "sample app", href: root_path, count: 1)
      expect(page).to(have_link "Home", href: root_path, count: 1)

      click_link "Home"
      expect(page).to(have_current_path root_path)
      expect(page).to(have_title full_title)
    end

    scenario "Helpリンクが正常に機能すること" do
      visit root_path
      expect(page).to(have_link "Help", href: help_path, count: 1)

      click_link "Help"
      expect(page).to(have_current_path help_path)
      expect(page).to(have_title full_title("Help"))
    end

    # Fixme
    # Log in機能を実装したらテストケースを修正する
    scenario "Log inリンク" do
      visit root_path
      expect(page).to(have_link "Log in", href: "#", count: 1)

      click_link "Log in"
      expect(page).to(have_current_path root_path)
      # expect(page).to(have_title full_title("XXX"))
    end
  end

  # ---------------
  # yieldに関するテスト
  # ---------------
  feature "Homeアクションのビューのリンクが正常に機能すること" do
    scenario "Singn up now!リンク" do
      visit root_path
      expect(page).to(have_link, href: signup_path, count: 1)

      click_link "Sign up now!"
      expect(page).to(have_current_path signup_path)
      # Fixme
      # Users#newのViewが完成次第テストケースを修正する
      expect(page).to(have_title full_title)
    end
  end

  # ---------------
  # Footerに関するテスト
  # ---------------
  feature "Footerにあるリンクが正常に機能すること" do
    scenario "Aboutリンクが正常に機能すること" do
      visit root_path
      expect(page).to(have_link "About", href: about_path, count: 1)

      click_link "About"
      expect(page).to(have_current_path about_path)
      expect(page).to(have_title full_title("About"))
    end

    scenario "Contactリンクが正常に機能すること" do
      visit root_path
      expect(page).to(have_link "Contact", href: contact_path, count: 1)

      click_link "Contact"
      expect(page).to(have_current_path contact_path)
      expect(page).to(have_title full_title("Contact"))
    end

    # 「News」は外部リンクなのでテストしない
  end
end

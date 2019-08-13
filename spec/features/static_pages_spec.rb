require "rails_helper"

RSpec.feature "StaticPages", type: :feature do
  feature "Headerにあるリンクが正常に機能すること" do
    scenario "Homeリンク(root_path)" do
      visit root_path
      click_link "Home"
      expect(page).to have_current_path root_path
    end

    scenario "Aboutリンク" do
      visit root_path
      click_link "About"
      expect(page).to have_current_path about_path
    end

    scenario "Helperリンク" do
      visit root_path
      click_link "About"
      expect(page).to have_current_path about_path
    end
  end

  feature "aタグのラベルとリンクが想定どおりであること" do
    scenario "sample app, Home-root_path" do
      visit root_path
      expect(page).to(have_link "sample app", href: root_path, count: 1)
      expect(page).to(have_link "Home", href: root_path, count: 1)
    end
    scenario "About-about_path" do
      visit root_path
      expect(page).to(have_link "About", href: about_path, count: 1)
    end
    scenario "Help-help_path" do
      visit root_path
      expect(page).to(have_link "Help", href: help_path, count: 1)
    end
  end
end

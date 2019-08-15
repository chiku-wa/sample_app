require "rails_helper"

RSpec.feature "StaticPages", type: :feature do
  feature "Headerにあるリンクが正常に機能すること" do
    scenario "Homeリンク(root_path)" do
      visit root_path
      click_link "Home"
      expect(page).to have_current_path root_path
    end

    scenario "Helpリンク" do
      visit root_path
      click_link "Help"
      expect(page).to have_current_path help_path
    end

    # Fixme
    # Log in機能を実装したらテストケースを修正する
    scenario "Log inリンク" do
      visit root_path
      click_link "Log in"
      expect(page).to have_current_path root_path
    end
  end

  feature "ページのタイトルが想定どおりであること" do
    scenario "Home" do
      visit root_path
      expect(page).to(have_title full_title)
    end
    scenario "Help" do
      visit help_path
      expect(page).to(have_title full_title("Help"))
    end

    # Fixme
    # Log in 機能を実装したらテストケースを修正する
    # scenario "Log in" do
    #   visit help_path
    #   expect(page).to(have_title full_title("Help"))
    # end

    scenario "About" do
      visit about_path
      expect(page).to(have_title full_title("About"))
    end

    scenario "Contact" do
      visit contact_path
      expect(page).to(have_title full_title("Contact"))
    end
  end

  feature "aタグのラベルとリンクが想定どおりであること" do
    scenario "sample app, Home => root_path" do
      visit root_path
      expect(page).to(have_link "sample app", href: root_path, count: 1)
      expect(page).to(have_link "Home", href: root_path, count: 1)
    end

    scenario "Help => help_path" do
      visit root_path
      expect(page).to(have_link "Help", href: help_path, count: 1)
    end

    # Fixme
    scenario "Log in => XXXX" do
      visit root_path
      expect(page).to(have_link "Log in", href: "#", count: 1)
    end

    scenario "About => about_path" do
      visit root_path
      expect(page).to(have_link "About", href: about_path, count: 1)
    end

    scenario "Contact => contact_path" do
      visit root_path
      expect(page).to(have_link "Contact", href: contact_path, count: 1)
    end
  end

  feature "Footerにあるリンククリックすると、想定通りのパスが返ってくること" do
    scenario "Aboutリンク" do
      visit root_path
      click_link "About"
      expect(page).to have_current_path about_path
    end

    scenario "Contactリンク" do
      visit root_path
      click_link "Contact"
      expect(page).to have_current_path contact_path
    end
  end
end

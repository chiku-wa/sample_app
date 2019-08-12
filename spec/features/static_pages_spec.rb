require "rails_helper"

RSpec.feature "StaticPages", type: :feature do
  scenario "linls root and Home" do
    # ルートにアクセスする
    visit root_path

    # 指定したinner HTMLのリンクが存在することを確認する
    # クリックするだけで
    click_link "Home"

    # 遷移したページが想定どおりであることを確認する
    expect(page).to have_current_path root_path
  end
end

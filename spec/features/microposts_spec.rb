require "rails_helper"

RSpec.feature "Microposts", type: :feature do
  before "テストユーザ登録" do
    # --- マイクロソフトの取得順序テスト用のデータ
    @user = FactoryBot.build(:user)
    @user.save

    [
      # テストを正確にするため、レコードの作成日時が古い順に登録する
      FactoryBot.build(:micropost_3years_ago),
      FactoryBot.build(:micropost_2hours_ago),
      FactoryBot.build(:micropost_10min_ago),
      FactoryBot.build(:micropost_latest),
    ].each do |m|
      @user.microposts.build(content: m.content, created_at: m.created_at)
    end
    @user.save
  end

  feature "投稿画面に関するテスト" do
    scenario "ログイン時のみ、TOP画面に投稿画面が表示されていること" do
      # 投稿フォームを示すxpath
      xpath_post_form = "//textarea[@id='micropost_content']"

      # 未ログイン時は投稿画面が表示されないこと
      visit root_path
      expect(page).to(have_xpath(xpath_post_form, count: 0))

      # ログイン時は投稿画面が表示されていること
      login_operation(@user)
      visit root_path
      expect(page).to(have_xpath(xpath_post_form, count: 1))

      # ログアウト後は投稿画面が表示されないこと
      logout_operation
      expect(page).to(have_xpath(xpath_post_form, count: 0))
    end
  end

  scenario "投稿後は、マイクロポスト一覧の先頭に投稿内容が表示されていること" do
    # 投稿画面を表示
    login_operation(@user)
    visit root_path

    # 投稿内容を定義
    post_content = Faker::Lorem.sentence

    # 投稿する
    fill_in("micropost_content", with: post_content)
    click_button("Post")

    # マイクロポスト一覧の先頭に表示されていること
    visit user_path(@user)
    expect(page.all("//li/span[@class='content']")[0]).to(have_content(post_content))
  end
end

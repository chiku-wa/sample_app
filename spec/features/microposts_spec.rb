require "rails_helper"

RSpec.feature "Microposts", type: :feature do
  # 投稿フォームの有無を確認するためのxpath
  let(:xpath_post_form) { "//textarea[@id='micropost_content']" }

  # マイクロポスト一覧の有無を確認するためのxpath
  let(:xpath_micropost_list) { "//ol[@class='microposts']" }

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
    scenario "ログインしている間のみ、TOP画面に投稿画面とマイクロポスト一覧が表示されていること" do
      # 未ログイン時は投稿画面とマイクロポスト一覧が表示されないこと
      visit root_path
      expect(page).to(have_xpath(xpath_post_form, count: 0))
      expect(page).to(have_xpath(xpath_micropost_list, count: 0))

      # ログイン時は投稿画面とマイクロポスト一覧が表示されていること
      login_operation(@user)
      visit root_path
      expect(page).to(have_xpath(xpath_post_form, count: 1))
      expect(page).to(have_xpath(xpath_micropost_list, count: 1))

      # ログアウト後は投稿画面とマイクロポスト投稿一覧が表示されないこと
      logout_operation
      expect(page).to(have_xpath(xpath_post_form, count: 0))
      expect(page).to(have_xpath(xpath_micropost_list, count: 0))
    end

    scenario "ログインしている間のみ、プロフィール画面にマイクロポスト一覧が表示されていること" do
      # 未ログイン時はマイクロポスト一覧が表示されないこと
      visit user_path(@user)
      expect(page).to(have_xpath(xpath_micropost_list, count: 0))

      # ログイン時はマイクロポスト一覧が表示されていること
      login_operation(@user)
      visit root_path
      expect(page).to(have_xpath(xpath_micropost_list, count: 1))
    end

    scenario "有効なマイクロポストを投稿する" do
      login_operation(@user)

      operation_post_micropost("a" * 140)

      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Micropost created!",
      )
    end

    scenario "無効なマイクロポストを投稿する" do
      login_operation(@user)

      # 上限を超えた文字数を投稿する
      operation_post_micropost("a" * 141)

      # エラー数が出力されていること
      expect(page).to(have_content(/The form contains 1 error*/))

      expect(page).to(have_content("Content is too long (maximum is 140 characters)", count: 1))
    end
  end

  scenario "投稿後は、マイクロポスト一覧の先頭に投稿内容が表示されていること" do
    login_operation(@user)

    # 投稿内容を定義
    post_content = Faker::Lorem.sentence

    operation_post_micropost(post_content)

    # TOP画面のマイクロポスト一覧の先頭に表示されていること
    expect(page).to(have_title(full_title))
    expect(page.all("//li/span[@class='content']")[0]).to(have_content(post_content))

    # ユーザプロフィールのマイクロポスト一覧の先頭に表示されていること
    visit user_path(@user)
    expect(page.all("//li/span[@class='content']")[0]).to(have_content(post_content))
  end

  # ======================================
  private

  # マイクロポストを投稿する操作
  def operation_post_micropost(post_content)
    # 投稿画面を表示
    visit root_path

    # 投稿する
    fill_in("micropost_content", with: post_content)
    click_button("Post")
  end
end

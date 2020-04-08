require "rails_helper"

RSpec.feature "Microposts", type: :feature do
  # 投稿フォームの有無を確認するためのxpath
  let(:xpath_post_form) { "//textarea[@id='micropost_content']" }

  # マイクロポスト一覧の画像の有無を確認するためのxpath
  let(:xpath_micropost_image) { "//li/span[@class='content']/img" }

  # マイクロポスト一覧の有無を確認するためのxpath
  let(:xpath_micropost_list) { "//ol[@class='microposts']" }

  # ===== 予め用意したテスト用画像の情報を定義
  # ディレクトリ
  let(:test_image_path) { File.join(Rails.root, "spec/fixtures") }
  # 正常系テスト用の画像ファイル名を定義
  let(:jpg_file_name) { "sample.jpg" }
  # 異常系テスト用の画像ファイル名を定義
  let(:bmp_file_name) { "sample.bmp" }

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
      visit user_path(@user)
      expect(page).to(have_xpath(xpath_micropost_list, count: 1))
    end

    scenario "ログインしている間のみ、TOP画面にマイクロポスト一覧が表示されていること" do
      # 未ログイン時はマイクロポスト一覧が表示されないこと
      visit root_url
      expect(page).to(have_xpath(xpath_micropost_list, count: 0))

      # ログイン時はマイクロポスト一覧が表示されていること
      login_operation(@user)
      visit root_path
      expect(page).to(have_xpath(xpath_micropost_list, count: 1))
    end

    scenario "本文のみでマイクロポストを正常に投稿できること" do
      login_operation(@user)

      expect {
        operation_post_micropost("a" * 140)
      }.to change(Micropost, :count).by(1)

      # 成功メッセージが表示されること
      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Micropost created!",
      )
    end

    scenario "許可された拡張子のファイルで正常に投稿できること" do
      login_operation(@user)

      expect {
        operation_post_micropost(
          "Image upload test.",
          "#{test_image_path}/#{jpg_file_name}",
        )
      }.to change(Micropost, :count).by(1)

      # マイクロポスト一覧の先頭に想定する画像がアップロードされていること
      # img要素のsrc属性をテストする
      expect(page).to(have_title(full_title))
      expect(
        page.all(xpath_micropost_image)[0][:src]
      ).to(have_content(jpg_file_name))

      # 成功メッセージが表示されること
      expect(page).to have_selector(
        ".alert.alert-success",
        text: "Micropost created!",
      )
    end

    scenario "許可されていない拡張子のファイルの場合は投稿できないこと" do
      login_operation(@user)

      expect {
        operation_post_micropost(
          "Image upload test.",
          "#{test_image_path}/#{bmp_file_name}",
        )
      }.to change(Micropost, :count).by(0)

      # マイクロポスト一覧img要素を持つマイクロポストが存在しないこと
      expect(page).to(have_title(full_title))
      expect(page.all(xpath_micropost_image)).not_to(have_content(bmp_file_name))

      # 失敗メッセージが表示されること
      expect(page).to have_selector(
        ".alert.alert-danger",
        text: "The form contains 1 error",
      )
      expect(page).to have_text(
        'Picture You are not allowed to upload "bmp" files, allowed types: jpg, jpeg, gif, png',
      )
    end

    scenario "無効な本文ではマイクロポストを投稿できないこと" do
      login_operation(@user)

      # 上限を超えた文字数を投稿する
      expect {
        operation_post_micropost("a" * 141)
      }.to change(Micropost, :count).by(0)

      # エラー数が出力されていること
      expect(page).to(have_content(/The form contains 1 error*/))

      expect(page).to(have_content("Content is too long (maximum is 140 characters)", count: 1))
    end

    scenario "正常に投稿できた後は、マイクロポスト一覧の先頭に投稿内容が表示されていること" do
      login_operation(@user)

      # 投稿内容を定義
      post_content = Faker::Lorem.sentence

      operation_post_micropost(post_content)

      # TOP画面のマイクロポスト一覧の先頭に表示されていること
      xpath_micropost_content = "//li/span[@class='content']"

      expect(page).to(have_title(full_title))
      expect(page.all(xpath_micropost_content)[0]).to(have_content(post_content))

      # ユーザプロフィールのマイクロポスト一覧の先頭に表示されていること
      visit user_path(@user)
      expect(page.all(xpath_micropost_content)[0]).to(have_content(post_content))
    end

    scenario "マイクロポストが削除できること" do
      login_operation(@user)

      # 期待値確認用に、マイクロポストの本文をXPathとして定義
      xpath_micropost_content = "//li/span[@class='content']"

      # TOP画面からマイクロポストを削除すると、1件削除されていること
      before_micropost_size = all(:xpath, xpath_micropost_content).size

      visit root_url
      expect {
        all(:xpath, "//li/span[@class='timestamp']/a[@data-method='delete']")[1].click
      }.to change(Micropost, :count).by(-1)

      after_micropost_size = all(:xpath, xpath_micropost_content).size

      expect(after_micropost_size).to eq (before_micropost_size - 1)
    end

    scenario "マイクロポスト削除後は、直前まで見ていた画面に遷移すること" do
      login_operation(@user)

      xpath_delete_button = "//li/span[@class='timestamp']/a[@data-method='delete']"

      # TOP画面からマイクロポストを削除すると、削除後はTOP画面に遷移すること
      visit root_url
      all(:xpath, xpath_delete_button)[1].click
      expect(page).to have_title(full_title)

      # プロフィール画面からマイクロポストを削除すると、削除後はプロフィール画面に遷移すること
      visit user_path(@user)
      all(:xpath, xpath_delete_button)[1].click
      expect(page).to have_title(full_title(@user.name))
    end
  end

  # ======================================
  private

  # 本文のみでマイクロポストを投稿する操作
  # 第2引数の画像がnilの場合は画像の添付は行わない
  def operation_post_micropost(post_content, image_path = nil)
    # 投稿画面を表示
    visit root_path

    # 投稿内容を入力
    fill_in("micropost_content", with: post_content)
    if image_path
      find(:xpath, "//*[@id='micropost_picture']").click
      attach_file(image_path)
    end

    # 投稿する
    click_button("Post")
  end
end

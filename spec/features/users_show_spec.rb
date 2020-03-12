require "rails_helper"

RSpec.feature "UsersShow", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)

    50.times do |i|
      content = "#{Faker::Lorem.sentence} #{i}"
      @user.microposts.build(content: content)
    end
    @user.save
  end

  feature "マイクロポスト一覧に関するテスト" do
    scenario "ページネーションバーが2つ存在すること" do
      login_operation(@user)
      expect_pagination_bar(2)
    end

    scenario "一度に表示されるマイクロポストが想定通りであること" do
      login_operation(@user)

      number_of_microposts_one = @user.microposts.paginate(page: nil).size
      expect_number_of_microposts(number_of_microposts_one)
    end
  end

  # ======================================
  private

  # 画面上に表示されたユーザ数が想定通りであることを確認するメソッド
  def expect_number_of_microposts(number_of_users)
    within(:css, ".microposts") do
      # マイクロポストのセクションが存在すること
      expect(page).to(have_css("li", id: /micropost-[0-9]+/, count: number_of_users))

      # ----- マイクロポストを構成する要素が存在すること
      # プロフィール画像
      expect(page).to(have_xpath("//li/a/img[@class='gravatar']", count: number_of_users))
      # ユーザ名
      expect(page).to(have_xpath("//li/span[@class='user']", count: number_of_users))
      # 投稿本文
      expect(page).to(have_xpath("//li/span[@class='content']", count: number_of_users))
      # 投稿日時
      expect(page).to(have_xpath("//li/span[@class='timestamp']", count: number_of_users))
    end
  end
end

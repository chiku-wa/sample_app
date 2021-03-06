require "rails_helper"

RSpec.feature "FollowerFolloweds", type: :feature do
  before "テストユーザ登録" do
    # ------ テスト用のユーザ、フォロー関係を登録する
    # * follower_user ー(フォロー)→ followed_user,followed_user_second
    # * follower_user ←(相互フォロー)→ follow_each_other_user
    # * independent_user ※フォローもフォロワーもなし
    @follower_user = FactoryBot.build(:follower_user)
    @follower_user.save
    @followed_user = FactoryBot.build(:followed_user)
    @followed_user.save
    @follow_each_other_user = FactoryBot.build(:follower_user_second)
    @follow_each_other_user.save
    @independent_user = FactoryBot.build(:user)
    @independent_user.save

    @follower_user.follow(@followed_user)
    @follower_user.follow(@follow_each_other_user)
    @follow_each_other_user.follow(@follower_user)
  end

  feature "Home画面に関するテスト" do
    scenario "フォロー数、フォロワー数が表示されていること" do
      login_operation(@follower_user)

      visit root_path

      expect_stat(@follower_user)
    end

    scenario "フォローユーザ一覧画面で、一度に表示されるユーザが30件であること" do
      # フォロー先ユーザを登録する
      generate_followed_users(followed_user_number_of: 35, follower_user: @follower_user)

      # ログインし、フォローユーザ一覧を表示する
      login_operation(@follower_user)
      click_link("following")
      expect(page).to(have_title(full_title("Following")))

      # 1ページ目(1ページに表示しきれない場合)は30件表示されること
      number_of_users_one = 30
      expect_number_of_users_follow(number_of_users_one)

      # 画面上部のNextを押下した場合に想定通りの結果が返ってくること
      click_link("Next →", match: :first)
      number_of_users_two = @follower_user.following.paginate(page: 2).each.size
      expect_number_of_users_follow(number_of_users_two)
    end

    scenario "フォロワー一覧画面で、一度に表示されるユーザが30件であること" do
      # フォロワーを登録する
      generate_follower_users(follower_user_number_of: 40, followed_user: @followed_user)

      # ログインし、フォローユーザ一覧を表示する
      login_operation(@followed_user)
      click_link("followers")
      expect(page).to(have_title(full_title("Followers")))

      # 1ページ目(1ページに表示しきれない場合)は30件表示されること
      number_of_users_one = 30
      expect_number_of_users_follow(number_of_users_one)

      # 画面上部のNextを押下した場合に想定通りの結果が返ってくること
      click_link("Next →", match: :first)
      number_of_users_two = @followed_user.followers.paginate(page: 2).each.size
      expect_number_of_users_follow(number_of_users_two)
    end
  end

  feature "プロフィール画面に関するテスト" do
    scenario "フォロー数、フォロワー数が表示されていること" do
      login_operation(@follower_user)

      visit user_path(@follower_user)

      expect_stat(@follower_user)
    end

    scenario "フォローしていないユーザならフォローボタンが、フォローしているユーザならフォロー解除ボタンが表示されること" do
      login_operation(@follower_user)

      # フォローしていないユーザならフォローボタンが表示されていること
      visit user_path(@independent_user)
      expect_follow_unfollow(follow: 1, unfollow: 0)

      # フォローしているユーザならフォロー解除ボタンが表示されていること
      visit user_path(@followed_user)
      expect_follow_unfollow(follow: 0, unfollow: 1)
    end

    scenario "フォローしていないユーザの場合はフォローできること" do
      login_operation(@follower_user)

      # フォローしていないユーザのプロフィール画面に遷移するとフォローボタンが表示されていること
      visit user_path(@independent_user)
      expect_follow_unfollow(follow: 1, unfollow: 0)

      # フォローボタンを押下するとプロフィール画面に遷移し、フォロー解除ボタンに切り替わること
      expect {
        click_button("Follow")
      }.to change(FollowerFollowed, :count).by(1)
      expect(page).to(have_title(full_title(@independent_user.name)))
      expect_follow_unfollow(follow: 0, unfollow: 1)

      # 統計情報が想定どおりであること
      expect_stat(@independent_user)
    end

    scenario "すでにフォロー済みのユーザの場合はフォロー解除できること" do
      login_operation(@follower_user)

      # フォロー済みのユーザのプロフィール画面に遷移するとフォロー解除ボタンが表示されていること
      visit user_path(@followed_user)
      expect_follow_unfollow(follow: 0, unfollow: 1)
      puts page.body
      # フォロー解除ボタンを押下するとプロフィール画面に遷移し、フォローボタンに切り替わること
      expect {
        click_button("Unfollow")
      }.to change(FollowerFollowed, :count).by(-1)
      expect(page).to(have_title(full_title(@followed_user.name)))
      expect_follow_unfollow(follow: 1, unfollow: 0)

      # 統計情報が想定どおりであること
      expect_stat(@followed_user)
    end

    scenario "フォローとフォロー解除を切り替えることができること" do
      login_operation(@follower_user)

      # フォローしていないユーザのプロフィール画面に遷移する
      visit user_path(@independent_user)
      expect_follow_unfollow(follow: 1, unfollow: 0)

      # フォローボタンを押下するとフォロー解除ボタンに切り替わること
      click_button("Follow")
      expect_follow_unfollow(follow: 0, unfollow: 1)

      # フォロー解除ボタンを謳歌するとフォローボタンに切り替わること
      click_button("Unfollow")
      expect_follow_unfollow(follow: 1, unfollow: 0)
    end
  end

  # ======================================
  private

  # 統計情報(フォロー数、フォロワー数)が表示されていることを確認するためのメソッド
  def expect_stat(user)
    # 統計を示すXpath
    xpath_stats = "//section[@class='stats']/div[@class='stats']"

    # フォロー数とリンクが表示されていること
    expect(
      page.all("#{xpath_stats}/a/strong[@id='following']/text()")[0]
    ).to(have_content(user.following.size))
    expect(page).to(
      have_xpath(
        "#{xpath_stats}/a[@href='#{following_user_path(user)}']",
        count: 1,
      )
    )

    # フォロワー数とリンクが表示されていること
    expect(
      page.all("#{xpath_stats}/a/strong[@id='followers']/text()")[0]
    ).to(have_content(user.followers.size))
    expect(page).to(
      have_xpath(
        "#{xpath_stats}/a[@href='#{followers_user_path(user)}']",
        count: 1,
      )
    )
  end

  # フォローボタン、フォロー解除ボタンが想定通り存在しているかを確認するためのメソッド
  def expect_follow_unfollow(follow:, unfollow:)
    # フォロー・フォロー解除ボタンが表示されるdivエリアのXpath
    xpath_follow_form = "//div[@id='follow_form']"

    # フォローボタン
    expect(page).to(
      have_xpath(
        "#{xpath_follow_form}/form[@id='follow']",
        count: follow,
      )
    )

    # フォロー解除ボタン
    expect(page).to(
      have_xpath(
        "#{xpath_follow_form}/form[@id='unfollow']",
        count: unfollow,
      )
    )
  end

  # 画面上に表示されたユーザ数が想定通りであることを確認するメソッド
  def expect_number_of_users_follow(number_of_users)
    within(:css, "//ul[@class=users]") do
      expect(page).to(have_css("li", count: number_of_users))
    end
  end
end

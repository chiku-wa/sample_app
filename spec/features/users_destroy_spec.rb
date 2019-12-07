require "rails_helper"

RSpec.feature "UsersDestroy", type: :feature do
  before "テストユーザを登録" do
    # 管理者権限を持つユーザを登録
    @admin_user = FactoryBot.build(:user)
    @admin_user.admin = true
    @admin_user.save

    # 一般ユーザを登録
    generate_test_users(10)
  end

  feature "ユーザ情報を削除する" do
    scenario "一覧から任意のユーザを削除する" do
      # 管理者でログインする
      login_operation(@admin_user)

      # ユーザ一覧画面に遷移する
      click_link("Account")
      click_link("Users")

      # 現在ログインしているユーザの削除リンクは表示されていないことを確認する
      expect(page).not_to(have_xpath("//a[@data-method='delete' and @href='#{user_path(@admin_user.id)}']"))
      # expect(html).to(have_css("link[rel='next']", visible: false))

      # 管理者以外のユーザの削除リンクが存在し、削除ボタンを押すとユーザが削除されること
      user = User.find_by(admin: false)
      expect {
        find(:xpath, "//a[@data-method='delete' and @href='#{user_path(user.id)}']").click
      }.to change(User, :count).by(-1)

      expect(User.find_by(id: user.id)).to be_nil
    end
  end
end

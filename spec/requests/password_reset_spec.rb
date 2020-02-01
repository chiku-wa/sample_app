require "rails_helper"

RSpec.describe "PasswordReset-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inactive = FactoryBot.build(:user_inactive)
    @user_inactive.save
  end

  it "パスワード再設定をリクエストすると、ダイジェスト・トークンが生成されメールが1通送信されること" do
    post password_resets_path, params: { "password_reset[email]": @user.email }

    # ダイジェストが生成され、生成日時がDBに登録されていること
    @user.reload
    expect(@user.reset_digest).not_to be_blank
    expect(@user.reset_sent_at).not_to be_blank

    # メールが送信されること
    expect(ActionMailer::Base.deliveries.size).to eq 1
  end

  it "存在しないメールアドレスでパスワード再設定をリクエストするとダイジェスト・トークンが生成されず、メールが送信されないこと" do
    post password_resets_path, params: { "password_reset[email]": "invalid.email" }
    expect(ActionMailer::Base.deliveries.size).to eq 0
  end

  it "有効化されていないユーザのメールアドレスでパスワード再設定をリクエストするとダイジェスト・トークンが生成されず、メールが送信されないこと" do
    post password_resets_path, params: { "password_reset[email]": @user_inactive }
    expect(ActionMailer::Base.deliveries.size).to eq 0
  end
end

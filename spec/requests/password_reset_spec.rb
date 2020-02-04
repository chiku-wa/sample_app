require "rails_helper"

RSpec.describe "PasswordReset-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inactive = FactoryBot.build(:user_inactive)
    @user_inactive.save
  end

  context "パスワード再設定リクエスト画面に関するテスト" do
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

  context "パスワード再設定画面に関するテスト" do
    it "パスワード再設定画面に正常に遷移すること" do
      # パスワード再設定トークンを設定する
      @user.create_reset_digest
      @user.save

      # パスワード再設定用画面にアクセス
      get edit_password_reset_path(@user.reset_token, email: @user.email)

      # パスワード再設定用画面が表示されること
      assert_template "password_resets/edit"
    end

    it "有効でないユーザの場合はTOP画面に遷移すること" do
      @user_inactive.create_reset_digest
      @user_inactive.save

      get edit_password_reset_path(@user_inactive.reset_token, email: @user_inactive.email)

      follow_redirect!
      assert_template "static_pages/home"
    end

    it "存在しないメールアドレスのユーザの場合はTOP画面に遷移すること" do
      @user.create_reset_digest
      @user.email = "invalid.email"
      @user.save

      get edit_password_reset_path(@user.reset_token, email: @user.email)

      follow_redirect!
      assert_template "static_pages/home"
    end

    it "トークンとダイジェストが一致しない場合はTOP画面に遷移すること" do
      @user.create_reset_digest
      @user.save
      @user.reset_token = "invalid_token"

      get edit_password_reset_path(@user.reset_token, email: @user.email)

      follow_redirect!
      assert_template "static_pages/home"
    end
  end
end

require "rails_helper"

RSpec.describe "AccountActivationsController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inacitve = FactoryBot.build(:user_inactive)
    @user_inacitve.save
  end

  context "正常に有効化できること" do
    it "有効化されていないユーザが正常に有効化できること" do
      expect(@user_inacitve.activated).to be_falsey

      get edit_account_activation_url(
        @user_inacitve.activation_token,
        email: @user_inacitve.email,
      )

      # ユーザが有効化されていること
      @user_inacitve.reload
      expect(@user_inacitve.activated).to be_truthy
      expect(@user_inacitve.activated_at).not_to be_blank

      # ログイン済みであること
      expect(session[:user_id]).not_to be_blank
    end
  end

  context "有効化されないこと" do
    it "すでに有効化されているユーザは、有効化処理が行われないこと" do
      expect(@user.activated).to be_truthy

      get edit_account_activation_url(
        @user.activation_token,
        email: @user.email,
      )

      # ログインされないこと
      expect(session[:user_id]).to be_blank
    end

    it "不正なメールアドレス、または有効かトークンの場合は有効化処理が行われないこと" do
      # ==========================================
      # ======不正なメールアドレスで有効化をリクエストする
      get edit_account_activation_url(
        @user_inacitve.activation_token,
        email: "invalid_address@dummy.com",
      )
      # ユーザが有効化されていないこと
      @user_inacitve.reload
      expect(@user_inacitve.activated).to be_falsey
      expect(@user_inacitve.activated_at).to be_blank

      # ログインされないこと
      expect(session[:user_id]).to be_blank

      # ==========================================
      # ======不正な有効化トークンで有効化をリクエストする
      get edit_account_activation_url(
        "invalid_token",
        email: @user_inacitve.email,
      )
      # ユーザが有効化されていないこと
      @user_inacitve.reload
      expect(@user_inacitve.activated).to be_falsey
      expect(@user_inacitve.activated_at).to be_blank

      # ログインされないこと
      expect(session[:user_id]).to be_blank
    end
  end
end

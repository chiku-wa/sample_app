require "rails_helper"

RSpec.describe SessionsHelper do
  before " " do
    # DBに保存するためのUserインスタンスを生成する
    @user = User.new(
      name: "Bob",
      email: "bob@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
    @user.save
  end

  context "log_inメソッド" do
    it "idがセッションに格納されること" do
      log_in(@user)
      expect(session[:user_id]).to eq(@user.id)
    end
  end

  context "current_userメソッド" do
    it "セッションに存在するユーザのidが格納されている場合は、Userオブジェクトを返すこと" do
      session[:user_id] = @user.id

      expect(current_user).to eq(@user)
    end

    it "セッションに存在しないユーザのidが格納されている場合は、nilを返すこと" do
      session[:user_id] = 99999

      expect(current_user).to eq(nil)
    end

    it "セッションにidが格納されていない場合は、CookieからユーザIDを読み取り、ログイン処理を行うこと" do
      # 前提条件として、セッションが空であること
      expect(session[:user_id]).to eq nil

      # CookieにユーザIDを格納する
      remember(@user)

      # セッションがない場合であっても、CookieからユーザIDを読み取り、ログイン処理を行うこと
      expect(current_user).to eq(@user)

      # ログイン処理が正常に行われいていること
      expect(session[:user_id]).not_to eq nil
    end
  end

  context "logged_inメソッド" do
    it "ログイン済み(current_userの戻り値がnilでない)の場合は、trueを返すこと" do
      session[:user_id] = @user.id

      expect(logged_in?).to eq(true)
    end

    it "ログインしていない(current_userの戻り値がnil)の場合は、falseを返すこと" do
      expect(logged_in?).to eq(false)
    end
  end

  context "logged_inメソッド" do
    it "セッションが破棄されること" do
      session[:user_id] = @user.id
      log_out

      expect(session[:user_id]).to eq(nil)
    end
  end

  context "rememberメソッド" do
    it "remember_tokenが発行され、cookiesに値が格納されていること" do
      remember(@user)

      expect(@user.remember_token).not_to eq nil

      # ユーザIDのCookieはsignedで暗号化しているため、取り出すときもsignedで復号化が必要
      expect(cookies.signed[:user_id]).to eq @user.id

      # 記憶トークンは暗号化していないため、複合化しなくとも良い
      expect(cookies[:remember_token]).to eq @user.remember_token
    end
  end
end

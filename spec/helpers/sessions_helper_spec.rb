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

      expect(current_user).to be_nil
    end

    it "セッションにidが格納されていない場合は、CookieからユーザIDを読み取り、ログイン処理を行うこと" do
      # 前提条件として、セッションが空であること
      expect(session[:user_id]).to be_blank

      # CookieにユーザIDを格納する
      remember(@user)

      # セッションがない場合であっても、CookieからユーザIDを読み取り、ログイン処理を行うこと
      expect(current_user).to eq(@user)

      # ログイン処理が正常に行われいていること
      expect(session[:user_id]).not_to be_blank
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

  context "log_outメソッド" do
    it "Cookieとセッションが破棄されること" do
      session[:user_id] = @user.id
      log_out

      expect(session[:user_id]).to be_nil
      expect(cookies[:user_id]).to be_nil
      expect(cookies[:remember_token]).to be_nil
    end
  end

  context "rememberメソッド" do
    it "記憶トークンがDBに登録され、CookieにユーザIDと記憶トークンが格納されていること" do
      remember(@user)

      expect(@user.remember_token).not_to be_blank

      # ユーザIDのCookieはsignedで暗号化しているため、取り出すときもsignedで復号化が必要
      expect(cookies.signed[:user_id]).to eq @user.id

      # 記憶トークンは暗号化していないため、複合化しなくとも良い
      expect(cookies[:remember_token]).to eq @user.remember_token
    end
  end

  context "forgetメソッド" do
    it "DBに登録された記憶トークンがnilになり、Cookieに登録されたユーザIDと記憶トークンが削除されること" do
      # 前提条件の確認(rememberメソッドのテストケースと同じ処理)
      remember(@user)
      expect(@user.remember_token).not_to be_blank
      expect(cookies[:remember_token]).to eq @user.remember_token

      # DBの記憶トークンにnilが登録され、Cookieが破棄されること
      forget(@user)
      expect(cookies[:user_id]).to be_blank
      expect(cookies[:remember_token]).to be_blank
    end
  end
end

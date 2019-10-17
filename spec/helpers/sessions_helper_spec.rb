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
      current_user

      expect(current_user).to eq(@user)
    end

    it "セッションに存在しないユーザのidが格納されている場合は、nilを返すこと" do
      session[:user_id] = 99999
      current_user

      expect(current_user).to eq(nil)
    end

    it "セッションにidが格納されていない場合は、nilを返すこと" do
      expect(current_user).to eq(nil)
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
end

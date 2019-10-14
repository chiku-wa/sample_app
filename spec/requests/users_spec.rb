require "rails_helper"

RSpec.describe "UsersController-requests", type: :request do
  before "edit,showなどの既存ユーザが必要なアクションをテストするためにユーザ登録を行う" do
    @user = User.new(
      name: "Tom",
      email: "tom@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
    @user.save
  end

  context "[new]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get new_user_path
      expect(response).to(have_http_status("200"))
    end
  end

  context "[show]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get user_path(@user.id)
      expect(response).to(have_http_status("200"))
    end
  end

  pending "[edit]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get edit_user_path(@user.id)
      expect(response).to(have_http_status("200"))
    end
  end

  pending "[destroy]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      delete user_path(@user.id)
      expect(response).to(have_http_status("200"))
    end
  end

  context "[signup]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get signup_path
      expect(response).to(have_http_status("200"))
    end
  end
end

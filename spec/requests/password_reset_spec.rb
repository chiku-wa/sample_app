require "rails_helper"

RSpec.describe "PasswordReset-requests", type: :request do
  context "[new]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get new_password_reset_path

      # パスワード再設定用画面に遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "password_resets/new"
    end
  end
end

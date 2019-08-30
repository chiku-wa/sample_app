require "rails_helper"

RSpec.describe "Users", type: :request do
  context "[new]アクションのViewレスポンスが想定どおりであること]" do
    it "HTTPレスポンス=200" do
      get signup_path
      expect(response).to have_http_status "200"
    end
  end
  context "[show]アクションのViewレスポンスが想定どおりであること]" do
    it "HTTPレスポンス=200" do
      get new_user_path
      expect(response).to have_http_status "200"
    end
  end
end

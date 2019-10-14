require "rails_helper"

RSpec.describe "StaticPagesController-requests", type: :request do
  context "ルートディレクトリ(homeアクション)のViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get root_path
      expect(response).to(have_http_status("200"))
    end
  end

  context "[help]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get help_path
      expect(response).to(have_http_status("200"))
    end
  end

  context "[about]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get about_path
      expect(response).to(have_http_status("200"))
    end
  end
  context "[contact]アクションのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get contact_path
      expect(response).to(have_http_status("200"))
    end
  end
end

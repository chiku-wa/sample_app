require "rails_helper"

RSpec.describe "StaticPagesController-requests", type: :request do
  # 期待値となるtitleタグの文字列を定義する
  let(:base_title) { " | Ruby on Rails Tutorial Sample App" }

  action_methods = [
    "home",
    "help",
    "about",
    "contact",
  ]

  context "ルートディレクトリのViewレスポンスが想定どおりであること" do
    it "HTTPレスポンス=200" do
      get get root_url
      expect(response).to have_http_status "200"
    end
  end

  action_methods.each do |action_method|
    context "[#{action_method}アクションのViewレスポンスが想定どおりであること]" do
      # 200ステータスが返ってくること
      it "HTTPレスポンス=200" do
        get "/static_pages/#{action_method}"
        expect(response).to have_http_status "200"
      end
    end
  end
end

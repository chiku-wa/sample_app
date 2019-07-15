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

      action_method_camel = action_method.camelize

      it "titleが想定通り" do
        get "/static_pages/#{action_method}"
        # Homeは特定の名称を使用、Home以外はアクション名(先頭大文字)を採用
        expect(response.body).to match(/(.+)<title>#{action_method_camel + base_title}<\/title>(.+)/)
      end
      it "h1タグが想定通り" do
        get "/static_pages/#{action_method}"

        # Homeは特定の名称を使用、Home以外はアクション名(先頭大文字)を採用
        reg_str = ""
        if action_method == "home"
          reg_str = "Sample App"
        else
          reg_str = action_method.camelize
        end
        expect(response.body).to match(/(.*)<h1>#{reg_str}<\/h1>(.*)/)
      end
    end
  end
end

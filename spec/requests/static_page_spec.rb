require "rails_helper"

RSpec.describe "StaticPages", type: :request do
  # 期待値となるtitleタグの文字列を定義する
  let(:base_title) { " | Ruby on Rails Tutorial Sample App" }

  action_methods = [
    "home",
    "help",
    "about",
  ]

  action_methods.each do |action_method|
    it "[#{action_method}]GETメソッドでリクエストを送り、200が返ってくることと、titleタグが想定通りの値となっていることを確認する" do
      get "/static_pages/#{action_method}"

      # 200ステータスが返ってくること
      expect(response).to have_http_status "200"

      # titleタグが想定した内容であること
      action_method_camel = action_method.camelize
      expect(response.body).to match(/(.+)<title>#{action_method_camel + base_title}<\/title>(.+)/)
    end
  end
end

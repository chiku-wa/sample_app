require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "アクションメソッドが指定したHTTPメソッドでリクエストした時に、正常なレスポンスが返ってくること" do
    # コントローラが内包するすべてのアクションメソッド名
    action_methods = [
      :new,
    ]

    context "Getメソッドのテスト" do
      action_methods.each do |action_method|
        it "アクションメソッド [#{action_method}]のテスト" do
          get action_method
          expect(response).to be_success
        end
      end
    end

    context "Postメソッドのテスト" do
      action_methods.each do |action_method|
        it "アクションメソッド [#{action_method}]のテスト" do
          post action_method
          expect(response).to be_success
        end
      end
    end
  end
end
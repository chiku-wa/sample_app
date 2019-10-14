require "rails_helper"

RSpec.describe "SessionsController-requests", type: :request do
  # Note: create,destroyアクションは対応するViewがないためHTTPメソッドのテストは行わない
  context "[new]アクションの挙動が想定どおりであること" do
    it "HTTPレスポンス=200" do
      get login_path
      expect(response).to(have_http_status("200"))
    end
  end
  pending "[destroy]アクションの挙動が想定どおりであること" do
    # Note: destroyアクションは対応するViewがないためHTTPメソッドのテストは行わない
    it "セッションが破棄されること" do
      # Fixme
    end
  end
end

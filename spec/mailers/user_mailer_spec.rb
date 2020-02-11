require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  before "テストユーザ登録とメール送信履歴の初期化" do
    # テストユーザ登録
    @user = FactoryBot.build(:user)
    @user.activation_token = User.new_token
    @user.create_reset_digest
    @user.save
  end

  context "ユーザ有効化用メール送信のテスト" do
    it "メール送信処理が成功すること" do
      mail = UserMailer.account_activation(@user)

      expect { mail.deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "送り主、宛先(To,Cc,Bcc)、件名、本文が想定通りであること" do
      mail = UserMailer.account_activation(@user)

      expect(mail.from).to eq ["noreply@example.com"]
      expect(mail.to).to eq [@user.email]
      expect(mail.cc).to be_nil
      expect(mail.bcc).to be_nil
      expect(mail.subject).to eq "ユーザ登録を完了してください"

      # 必要な情報が含まれていること
      expected_body(mail, @user.name)
      expected_body(mail, @user.activation_token)
      expected_body(mail, CGI.escape(@user.email))
    end
  end

  context "パスワード再設定用メール送信のテスト" do
    it "メール送信処理が成功すること" do
      mail = UserMailer.password_reset(@user)

      expect { mail.deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "送り主、宛先(To,Cc,Bcc)、件名、本文が想定通りであること" do
      mail = UserMailer.password_reset(@user)

      expect(mail.from).to eq ["noreply@example.com"]
      expect(mail.to).to eq [@user.email]
      expect(mail.cc).to be_nil
      expect(mail.bcc).to be_nil
      expect(mail.subject).to eq "パスワードを再設定してください"

      # 必要な情報が含まれていること
      expected_body(mail, @user.name)
      expected_body(mail, @user.reset_token)
      expected_body(mail, CGI.escape(@user.email))

      # ---Fixme 以下の記述方法ではパスワード再設定のリンク文字のテストがパスしないため修正する
      # expected_body(mail, edit_password_reset_url(@user.reset_token, email: @user.email))
    end
  end
end

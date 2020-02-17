class UserMailer < ApplicationMailer
  # アカウント有効化用メールを送信するメソッド
  def account_activation(user)
    @user = user
    mail(
      to: user.email,
      subject: "ユーザ登録を完了してください",
    )
  end

  # パスワード再設定用メールを送信するメソッド
  def password_reset(user)
    @user = user
    mail(
      to: user.email,
      subject: "パスワードを再設定してください",
    )
  end
end

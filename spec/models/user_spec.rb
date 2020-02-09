require "rails_helper"

RSpec.describe "Userモデルのテスト", type: :model do
  before do
    # DBに保存するためのUserインスタンスを生成する
    @user = User.new(
      name: "Tom",
      email: "Tom@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
  end

  context "事前確認用テスト" do
    it "ユーザ情報が有効であること" do
      expect(@user).to be_valid
    end
  end

  context "バリデーションのテスト" do
    # --- nameのテスト
    it "nameが空白の場合はバリデーションエラーとなること" do
      @user.name = ""
      expect(@user).not_to be_valid
    end

    it "nameが規定の最大文字数を超えている場合はバリデーションエラーとなること" do
      @user.name = "a" * 51
      expect(@user).not_to be_valid
    end

    # --- emailのテスト
    it "emailが空白の場合はバリデーションエラーとなること" do
      @user.email = ""
      expect(@user).not_to be_valid
    end

    it "emailが規定の最大文字数を超えている場合はバリデーションエラーとなること" do
      @user.email = "#{("a" * 244)}@example.com"
      expect(@user).not_to be_valid
    end

    it "emailが有効な文字列の組み合わせであればバリデーションを通過すること" do
      valid_addresses = [
        "user@example.com",
        "USER@foo.COM",        # @より前とCOMが大文字
        "A_US-ER@foo.bar.org", # ハイフンあり
        "first.last@foo.jp",   # ドメインがjp
        "alice+bob@baz.cn",    # @よりまえに+を含む文字あり、ドメインがbar.cn
      ]
      valid_addresses.each do |valid_addrress|
        @user.email = valid_addrress
        expect(@user).to be_valid, "#{valid_addrress} shoud be valid"
      end
    end

    it "emailが不正な文字列の組み合わせであればバリデーションエラーとなること" do
      invalid_addresses = [
        "user@example,com",   # .ではなく,
        "user_at_foo.org",    # @ではなく.
        "user.name@example.", # .で終わっている
        "foo@bar_baz.com",    # _あり
        "user@example..com",  # .が連続して存在
      ]
      invalid_addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid, "#{invalid_address} should be invalid"
      end
    end

    it "重複したemailでユーザ登録しようとした場合はバリデーションエラーとなること" do
      duplicate_user = @user.dup
      duplicate_user.email = @user.email.upcase
      @user.save
      expect(duplicate_user).not_to be_valid
    end

    # --- passwordのテスト
    it "passwordが空白の場合はバリデーションエラーとなること" do
      @user.password = @user.password_confirmation = ""
      expect(@user).not_to be_valid
    end

    it "passwordに空白しか存在しない場合はバリデーションエラーとなること" do
      @user.password = @user.password_confirmation = " " * 6
      expect(@user).not_to be_valid
    end

    it "passwordが最小文字数を下回る場合はバリデーションエラーとなること" do
      @user.password = @user.password_confirmation = "a" * 5
      expect(@user).not_to be_valid
    end
  end

  context "バリデーション以外のテスト" do
    it "emailが小文字に変換されて登録されること" do
      mixed_case_email = "Tom@example.com"
      @user.email = mixed_case_email
      @user.save
      expect(@user.email).to eq mixed_case_email.downcase
    end

    it "digestメソッドの戻り値が、引数で渡した文字列と異なっていること" do
      str = "FooBar"
      expect(User.digest(str)) != str
    end

    it "rememberメソッドを実行すると、DBにトークンが登録されること" do
      @user.save
      @user.remember

      user = User.find_by(id: @user.id)

      # DBにremember_digestが登録されていること
      expect(user.remember_digest).not_to be_blank

      # Userインスタンスが保持するremember_tokenと、DBに登録されているremember_digest
      # のトークン値が異なっていること(暗号化されていることの確認)
      expect(@user.remember_token).not_to eq user.remember_digest
    end

    it "forgetメソッドを実行すると、DBに登録されたトークンがnilになること" do
      @user.save
      @user.remember

      user = User.find_by(id: @user.id)

      # DBにremember_digestが登録されていること
      expect(user.remember_digest).not_to be_blank

      # DBに登録されたremember_digestが削除されること
      @user.forget
      user.reload
      expect(user.remember_digest).to be_blank
    end

    it "authenticated?メソッドで、記憶トークンが等しい場合はtrueを返すこと" do
      @user.save
      @user.remember

      expect(@user.authenticated?(:remember, @user.remember_token)).to be_truthy
    end

    it "authenticated?メソッドで、記憶トークンが異なる場合はfalseを返すこと" do
      @user.save
      @user.remember

      @user.remember_token = "FooBar"

      expect(@user.authenticated?(:remember, @user.remember_token)).to be_falsey
    end

    it "authenticated?メソッドで、remember_digestがnilだった場合にfalseを返すこと" do
      @user.save
      @user.remember

      @user.remember_token = "FooBar"
      @user.remember_digest = nil

      expect(@user.authenticated?(:remember, @user.remember_token)).to be_falsey
    end

    it "acitvateメソッドで、有効化フラグと有効化した日時が登録されること" do
      expect(@user.activated).to be_falsey
      expect(@user.activated_at).to be_blank

      @user.activate

      expect(@user.activated).to be_truthy
      expect(@user.activated_at).not_to be_blank
    end

    it "send_activation_mailメソッドで、メールが1通送信されること" do
      @user.save
      @user.send_activation_mail

      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    it "create_activation_digestメソッドで、有効化トークン・ダイジェストが期待通りであること" do
      # 保存前は有効化トークンと有効化ダイジェストはnilであること
      expect(@user.activation_token).to be_blank
      expect(@user.activation_digest).to be_blank

      @user.save

      # 保存後はトークンとダイジェストに値が設定されていること
      expect(@user.activation_token).not_to be_blank
      expect(@user.activation_digest).not_to be_blank

      # トークンとダイジェストが一致すること
      expect(@user.authenticated?(:activation, @user.activation_token)).to be_truthy
    end

    it "create_reset_digestメソッドで、パスワード再設定用トークン・ダイジェストが期待通りであること" do
      @user.save

      # 保存前は有効化トークンと有効化ダイジェストはnilであること
      expect(@user.reset_token).to be_blank
      expect(@user.reset_digest).to be_blank

      @user.create_reset_digest

      # 保存後はトークンとダイジェストに値が設定されていること
      # DBに保存されていることを期待するためreloadする
      @user.reload
      expect(@user.reset_token).not_to be_blank
      expect(@user.reset_digest).not_to be_blank

      # トークンとダイジェストが一致すること
      expect(@user.authenticated?(:reset, @user.reset_token)).to be_truthy
    end

    it "password_reset_expired?メソッドで、reset_sent_atの日時から2時間経過していたら
      期限切れとみなすこと" do
      # パスワード再設定ダイジェストとトークンを発行する
      @user.create_reset_digest
      @user.save

      @user.reset_sent_at = @user.reset_sent_at
        .ago(2.hours)
      expect(@user.password_reset_expired?).to be_truthy
    end

    it "password_reset_expired?メソッドで、reset_sent_atの日時から1時間59分経過していたら
      期限切れと【みなさない】こと" do
      # パスワード再設定ダイジェストとトークンを発行する
      @user.create_reset_digest
      @user.save

      @user.reset_sent_at = @user.reset_sent_at
        .ago(1.hours)
        .ago(59.minutes)
      expect(@user.password_reset_expired?).to be_falsey
    end
  end
end

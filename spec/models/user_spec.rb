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

  context "テストデータの事前確認用テスト" do
    it "テストデータを加工していない場合はバリデーションを通過すること" do
      expect(@user).to be_valid
    end
  end

  context "バリデーションのテスト" do
    # --- nameのテスト
    it "nameがスペース、空文字のみの場合はバリデーションエラーとなること" do
      # 半角スペース
      @user.name = " "
      expect(@user).not_to be_valid

      # 全角スペース
      @user.name = "　"
      expect(@user).not_to be_valid

      # 空文字
      @user.name = ""
      expect(@user).not_to be_valid
    end

    it "nameが規定の最大文字数(全角、半角区別なし)を超えている場合はバリデーションエラーとなること" do
      # 半角51文字はバリデーションエラーとなること
      @user.name = "a" * 51
      expect(@user).not_to be_valid

      # 全角50文字は許容されること(バイトが判断基準になっていないこと)
      @user.name = "あ" * 50
      expect(@user).to be_valid

      # 全角51文字はバリデーションエラーとなること
      @user.name = "あ" * 51
      expect(@user).not_to be_valid
    end

    # --- emailのテスト
    it "emailが空白の場合はバリデーションエラーとなること" do
      # 半角スペース
      @user.email = " "
      expect(@user).not_to be_valid

      # 全角スペース
      @user.email = "　"
      expect(@user).not_to be_valid

      # 空文字
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

  context "マイクロポスト関連のテスト" do
    it "ユーザが削除された場合、関連するマイクロポストが削除されること" do
      # マイクロポストデータ作成
      micropost_latest = FactoryBot.build(:micropost_latest)
      @user.microposts.build(
        content: micropost_latest.content,
        created_at: micropost_latest.created_at,
      )
      @user.save

      # 削除する前はマイクロポストが存在すること
      expect(@user.microposts.size).to eq 1

      # 破壊的メソッドを使って、テスト失敗時に例外を発生させて原因が特定できるようにする
      @user.destroy!

      # ユーザ削除後はマイクロポストが削除されていること
      expect(@user.microposts.size).to eq 0
    end
  end

  context "フォロー機能のテスト" do
    it "指定したユーザをフォローできること" do
      @user.save

      # フォローするユーザを作成する
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォロー情報が登録されていること
      expect {
        # フォローする
        @user.follow(followed_user)

        # バリデーションを通過すること
        expect(@user).to be_valid
      }.to change(FollowerFollowed, :count).by(1)

      # 想定した件数、内容が登録されていること
      follower_followeds = FollowerFollowed.where({
        follower_id: @user.id,
        followed_id: followed_user.id,
      })
      expect(follower_followeds.size).to eq 1
    end

    it "すでにフォロー済みのユーザをフォローしようとした場合はエラーにならないこと" do
      @user.save

      # フォローするユーザを作成する
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォロー情報が登録されていること
      expect {
        # フォローする
        @user.follow(followed_user)

        # バリデーションを通過すること
        expect(@user).to be_valid
      }.to change(FollowerFollowed, :count).by(1)

      # 2回目のフォローでエラーにならないこと
      expect {
        # フォローする
        @user.follow(followed_user)
      }.not_to raise_error
    end

    it "フォローしているユーザを確認できること" do
      @user.save

      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      followed_user_second = User.new(
        name: "Bob",
        email: "Bob@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user_second.save

      # フォローする
      @user.follow(followed_user)
      @user.follow(followed_user_second)

      # フォローしているユーザが取得できること
      expect(@user.following?(followed_user)).to be_truthy
      expect(@user.following?(followed_user_second)).to be_truthy
    end

    it "フォローを解除できること" do
      @user.save

      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォローする
      @user.follow(followed_user)
      expect(@user.following.size).to eq 1

      # フォロー解除する
      @user.unfollow(followed_user)
      expect(@user.following.size).to eq 0
    end

    it "すでにフォロー解除済みのユーザーをフォロー解除しようとしてもエラーにならないこと" do
      @user.save

      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォローする
      @user.follow(followed_user)
      expect(@user.following.size).to eq 1

      # フォロー解除する
      @user.unfollow(followed_user)
      expect(@user.following.size).to eq 0

      # 2回目のフォロー解除でエラーにならないこと
      expect {
        @user.unfollow(followed_user)
      }.not_to raise_error
    end

    it "フォローもとのユーザが削除された場合はフォロー情報が削除されること" do
      @user.save

      # フォローするユーザを作成する
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォローする
      @user.following << followed_user

      # 削除されたユーザがフォロワーとなっているフォロー情報が削除されること
      expect {
        @user.destroy
      }.to change(FollowerFollowed, :count).by(-1)

      follower_followeds = FollowerFollowed.where({
        follower_id: @user.id,
      })
      expect(follower_followeds.size).to eq 0
    end

    it "フォロー先のユーザが削除されてもフォロー情報が残ること" do
      # フォローするユーザを作成する
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # フォローする
      @user.following << followed_user

      # フォローしているユーザを削除しても、フォロー情報は削除されないこと
      expect {
        followed_user.destroy
      }.to change(FollowerFollowed, :count).by(0)
    end
  end

  context "フィード機能のテスト" do
    it "自身とフォローしているユーザのマイクロポストの一覧が取得できること" do
      @user.save

      # フォローするユーザを作成しフォローする
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save
      @user.follow(followed_user)

      # 自分自身のマイクロポストを登録する
      [
        FactoryBot.build(:micropost_2hours_ago),
        FactoryBot.build(:micropost_latest),
      ].each do |m|
        @user.microposts.build(content: m.content, created_at: m.created_at)
      end
      @user.save

      # フォローしているユーザのマイクロポストを登録する
      [
        FactoryBot.build(:micropost_3years_ago),
        FactoryBot.build(:micropost_10min_ago),
      ].each do |m|
        followed_user.microposts.build(content: m.content, created_at: m.created_at)
      end
      followed_user.save

      # フォローしていないユーザのマイクロポストを登録する
      unfollowed_user = User.new(
        name: "Bob",
        email: "Bob@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      unfollowed_user.save
      [
        FactoryBot.build(:micropost_3years_ago),
        FactoryBot.build(:micropost_2hours_ago),
        FactoryBot.build(:micropost_10min_ago),
        FactoryBot.build(:micropost_latest),
      ].each do |m|
        unfollowed_user.microposts.build(content: m.content, created_at: m.created_at)
      end
      unfollowed_user.save

      # 投稿日時の件数が想定通りであることを確認する
      expect(@user.feed.size).to eq 4
    end
  end

  context "その他のテスト" do
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

      @user.reset_sent_at = @user.reset_sent_at.ago(2.hours)
      expect(@user.password_reset_expired?).to be_truthy
    end

    it "password_reset_expired?メソッドで、reset_sent_atの日時から1時間59分経過していたら
      期限切れと【みなさない】こと" do
      # パスワード再設定ダイジェストとトークンを発行する
      @user.create_reset_digest
      @user.save

      @user.reset_sent_at = @user.reset_sent_at.ago(1.hours).ago(59.minutes)
      expect(@user.password_reset_expired?).to be_falsey
    end
  end
end

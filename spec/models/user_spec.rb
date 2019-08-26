require "rails_helper"

RSpec.describe "Userモデルのテスト", type: :model do
  before do
    # DBに保存するためのUserインスタンスを生成する
    @user = User.new(
      name: "Tom",
      email: "tom@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
  end

  it "ユーザ情報が有効であること" do
    expect(@user).to be_valid
  end

  it "nameが設定されていること" do
    @user.name = ""
    expect(@user).not_to be_valid
  end

  it "emailが設定されていること" do
    @user.email = ""
    expect(@user).not_to be_valid
  end

  it "nameの最大文字数バリデーションが有効であること" do
    @user.name = "a" * 51
    expect(@user).not_to be_valid
  end

  it "emailの最大文字数バリデーションが有効であること" do
    @user.email = "#{("a" * 244)}@example.com"
    expect(@user).not_to be_valid
  end

  it "emailaが有効な文字列の組み合わせであればバリデーションを通過すること" do
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

  it "emailaが不正な文字列の組み合わせであればバリデーションエラーとなること" do
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

  it "重複したメールアドレスはバリデーションエラーとなること" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    expect(duplicate_user).not_to be_valid
  end

  it "emailが小文字に変換されて登録されること" do
    mixed_case_email = "Tom@example.com"
    @user.email = mixed_case_email
    @user.save
    expect(@user.email).to eq mixed_case_email.downcase
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

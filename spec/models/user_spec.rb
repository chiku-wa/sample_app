require "rails_helper"

RSpec.describe User, type: :model do
  before do
    # DBに保存するためのUserインスタンスを生成する
    @user = User.new(
      name: "Tom",
      email: "tom@example.com",
    )

    #
  end

  it "should be valid" do
    expect(@user).to be_valid
  end

  it "name should be present" do
    @user.name = ""
    expect(@user).not_to be_valid
  end

  it "email should be present" do
    @user.email = ""
    expect(@user).not_to be_valid
  end

  it "name should not be too long" do
    @user.name = "a" * 51
    expect(@user).not_to be_valid
  end

  it "email should not be too long" do
    @user.email = "#{("a" * 244)}@example.com"
    expect(@user).not_to be_valid
  end

  it "email validation should accept valid addresses" do
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

  it "email validation should reject invalid addresses" do
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

  it "email address should be uniuque" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    expect(duplicate_user).not_to be_valid
  end

  it "email addresses should be saved as lower-case" do
    mixed_case_email = "Tom@example.com"
    @user.email = mixed_case_email
    @user.save
    expect(@user.email).to eq mixed_case_email.downcase
  end
end

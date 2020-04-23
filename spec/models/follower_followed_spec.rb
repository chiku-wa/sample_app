require "rails_helper"

RSpec.describe "FollowerFollowedモデルのテスト", type: :model do
  context "従属関係のテスト" do
    it "フォワー、フォローされているユーザが取得できること(従属関係のテスト)" do
      # テストユーザ：フォロワーユーザ
      follower_user = User.new(
        name: "Cacy",
        email: "Cacy@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      follower_user.save

      # テストユーザ：フォローされるユーザ
      followed_user = User.new(
        name: "Alice",
        email: "Alice@example.com",
        password: "foobar",
        password_confirmation: "foobar",
      )
      followed_user.save

      # ユーザをフォローする
      follower_user.followeds.build(followed_id: followed_user.id)
      follower_user.save

      # フォロワー一覧、フォローされているユーザが取得できること
      ff = FollowerFollowed.first
      expect(ff.follower).to eq follower_user
      expect(ff.followed).to eq followed_user
    end
  end
end

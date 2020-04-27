require "rails_helper"

RSpec.describe "FollowerFollowedモデルのテスト", type: :model do
  before do
    # フォロワーユーザ
    @follower_user = FactoryBot.build(:follower_user)
    @follower_user.save

    # フォローされるユーザ
    @followed_user = FactoryBot.build(:followed_user)
    @followed_user.save
  end

  context "バリデーションのテスト" do
    # --- follower_id,followed_idのテスト
    it "follower_id,followed_idのいずれかがnilの場合はエラーとなること" do
      @follower_user.followeds.build(followed_id: @followed_user.id)
      @follower_user.save
      follower_followed = @follower_user.followeds.first

      expect(follower_followed).to be_valid

      # follower_idがnilの場合はバリデーションエラーとなること
      follower_followed.follower_id = nil
      expect(follower_followed).not_to be_valid

      follower_followed.reload

      # follwerd_idがnilの場合はバリデーションエラーとなること
      follower_followed.followed_id = nil
      expect(follower_followed).not_to be_valid
    end
    it "同じfollower_id,followed_idの組み合わせを持つレコードの場合はバリデーションエラーとなること" do
      # バリエーションテストのためのユーザを登録
      follower_user_second = FactoryBot.build(:follower_user_second)
      follower_user_second.save
      followed_user_second = FactoryBot.build(:followed_user_second)
      followed_user_second.save

      # フォローする
      @follower_user.followeds.build(followed_id: @followed_user.id)
      @follower_user.save
      follower_user_second.followeds.build(followed_id: followed_user_second.id)
      follower_user_second.save

      # 同じfollower_id,followed_idの組み合わせの場合はエラーとなること
      expect(
        @follower_user.followeds.build(followed_id: @followed_user.id)
      ).not_to be_valid
      expect(
        follower_user_second.followeds.build(followed_id: followed_user_second.id)
      ).not_to be_valid

      # 異なる組み合わせの同じfollower_id,followed_idの場合はエラーとならないこと
      expect(
        @follower_user.followeds.build(followed_id: followed_user_second.id)
      ).to be_valid
      expect(
        follower_user_second.followeds.build(followed_id: @followed_user.id)
      ).to be_valid
    end
  end

  context "従属関係のテスト" do
    it "フォワー、フォローされているユーザが取得できること(従属関係のテスト)" do
      # ユーザをフォローする
      @follower_user.followeds.build(followed_id: @followed_user.id)
      @follower_user.save

      # フォロワー、フォローされているユーザが取得できること
      follower_followed = FollowerFollowed.first
      expect(follower_followed.follower).to eq @follower_user
      expect(follower_followed.followed).to eq @followed_user
    end
  end
end

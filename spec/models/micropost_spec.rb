require "rails_helper"

RSpec.describe "Userモデルのテスト", type: :model do
  # アップロードした画像が保存されるディレクトリの定義(Publicディレクトリからの相対パス)
  let(:image_save_dir) { "/uploads/micropost/picture" }

  before do
    user = User.new(
      name: "Tom",
      email: "cacy@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
    user.save

    @micropost = user.microposts.build(
      content: "Test message.",
    )
  end

  context "テストデータの事前確認用テスト" do
    it "テストデータを加工していない場合はバリデーションを通過すること" do
      expect(@micropost).to be_valid
    end
  end

  context "バリデーションのテスト" do
    # --- userのテスト
    it "user,user_idがnilの場合はバリデーションエラーとなること" do
      @micropost.user = nil
      expect(@micropost).not_to be_valid

      @micropost.user_id = nil
      expect(@micropost).not_to be_valid
    end

    # --- contentのテスト
    it "本文が140文字(全角、半角区別なし)を超える場合はバリデーションエラーとなること" do
      # 半角141文字はバリデーションエラーとなること
      @micropost.content = "a" * 141
      expect(@micropost).not_to be_valid

      # 全角140文字は許容されること(バイトが判断基準になっていないこと)
      @micropost.content = "あ" * 140
      expect(@micropost).to be_valid

      # 全角141文字はバリデーションエラーとなること
      @micropost.content = "あ" * 141
      expect(@micropost).not_to be_valid
    end

    it "本文がスペース、空文字のみの場合はバリデーションエラーとなること" do
      # 半角スペース
      @micropost.content = " "
      expect(@micropost).not_to be_valid

      # 全角スペース
      @micropost.content = "　"
      expect(@micropost).not_to be_valid

      # 空文字
      @micropost.content = ""
      expect(@micropost).not_to be_valid
    end
  end

  context "その他のテスト" do
    it "画像を保存できること" do
      # テスト用の画像変数を定義
      image_file_name = "sample.jpg"
      image_path = File.join(Rails.root, "spec/fixtures/#{image_file_name}")
      image = Rack::Test::UploadedFile.new(image_path)

      # バリデーションエラーが発生していないこと
      @micropost.picture = image
      @micropost.save
      expect(@micropost).to be_valid

      # 画像が保存されていること
      @micropost.reload
      expect(@micropost.picture.to_s).to eq "#{image_save_dir}/#{@micropost.id}/#{image_file_name}"
    end
  end
end
